import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'answer_button.dart';
import 'image_card.dart';

/// Une question telle que définie dans assets/themes/<theme>.json.
/// Reprend exactement les 3 champs vérifiés par test_files_exist() /
/// test_questions() dans ton script : id, image, answer.
class QuestionData {
  const QuestionData({
    required this.id,
    required this.image,
    required this.answer,
    this.difficulty,
    this.type,
    this.environment,
    this.explanation,
  });

  final String id;

  /// Chemin de l'image RELATIF à assets/images/, ex: 'plantes/bambou.webp'.
  /// Le sous-dossier du thème est déjà inclus dans cette valeur.
  final String image;
  final String answer;

  /// Champs optionnels : présents dans ton JSON mais pas indispensables
  /// au fonctionnement du jeu. Utiles plus tard pour filtrer par niveau
  /// (difficulty), catégoriser (type/environment) ou afficher une
  /// explication après la réponse.
  final int? difficulty;
  final String? type;
  final String? environment;
  final String? explanation;

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      id: json['id'].toString(),
      image: json['image'].toString(),
      answer: json['answer'].toString(),
      difficulty: json['difficulty'] == null ? null : int.tryParse(json['difficulty'].toString()),
      type: json['type']?.toString(),
      environment: json['environment']?.toString(),
      explanation: json['explanation']?.toString(),
    );
  }
}

/// Un mot du wordpool (assets/wordpool/<theme>_words.json).
/// On ne se sert ici que de `word`, mais `type`/`environment`/`difficulty`
/// sont gardés pour le jour où tu voudras filtrer les mauvaises réponses
/// (ex: ne piocher que des mots de même difficulté).
class WordEntry {
  const WordEntry({
    required this.word,
    required this.type,
    required this.environment,
    required this.difficulty,
  });

  final String word;
  final String type;
  final String environment;
  final String difficulty;

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      word: json['word'].toString(),
      type: json['type'].toString(),
      environment: json['environment'].toString(),
      difficulty: json['difficulty'].toString(),
    );
  }
}

/// Charge un thème (questions + wordpool) depuis les assets et sait
/// générer un jeu de 4 réponses pour une question donnée.
/// C'est la traduction directe de load_json() / generate_answers()
/// de ton test_plantes.py.
class ThemeRepository {
  ThemeRepository(this.themeName);

  /// Nom du thème, ex: 'plantes'. Sert à retrouver
  /// assets/themes/plantes.json, assets/wordpool/plantes_words.json
  /// et le dossier assets/images/plantes/.
  final String themeName;

  List<QuestionData> questions = [];
  List<WordEntry> words = [];

  Future<void> load() async {
    final themeJson = jsonDecode(
      await rootBundle.loadString('assets/themes/$themeName.json'),
    ) as Map<String, dynamic>;

    final wordpoolJson = jsonDecode(
      await rootBundle.loadString('assets/wordpool/${themeName}_words.json'),
    ) as Map<String, dynamic>;

    questions = (themeJson['questions'] as List)
        .map((q) => QuestionData.fromJson(q as Map<String, dynamic>))
        .toList();

    words = (wordpoolJson['words'] as List)
        .map((w) => WordEntry.fromJson(w as Map<String, dynamic>))
        .toList();

    if (questions.isEmpty) {
      throw StateError('Aucune question trouvée dans $themeName.json');
    }
  }

  /// Chemin complet de l'image d'une question.
  /// question.image contient déjà le sous-dossier du thème
  /// (ex: 'plantes/cactus.webp'), donc on préfixe juste par assets/images/.
  String imagePathFor(QuestionData question) {
    return 'assets/images/${question.image}';
  }

  /// Équivalent de generate_answers() en Python :
  /// la bonne réponse + 3 mauvaises réponses tirées au hasard dans le
  /// wordpool (en excluant la bonne réponse), puis le tout mélangé.
  List<String> generateAnswers(QuestionData question) {
    final candidates = words
        .map((w) => w.word)
        .where((word) => word != question.answer)
        .toList()
      ..shuffle();

    final wrongAnswers = candidates.take(3).toList();

    final answers = [question.answer, ...wrongAnswers]..shuffle();
    return answers;
  }
}

const int _maxLives = 3;
const Duration _feedbackDuration = Duration(milliseconds: 950);

class GamePage extends StatefulWidget {
  const GamePage({super.key, this.themeName = 'plantes'});

  /// Quel thème charger. Change juste cette valeur (ou passe-la
  /// depuis l'écran de sélection de niveau) pour jouer sur un autre thème
  /// (animaux, drapeaux, taekwondo, voitures...).
  final String themeName;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final ThemeRepository _repository = ThemeRepository(widget.themeName);

  // --- Chargement des données ---
  bool _isLoading = true;
  String? _loadError;

  // --- État du jeu (inchangé par rapport à la version précédente) ---
  int _index = 0;
  int _lives = _maxLives;
  int _score = 0;
  int _elapsedSeconds = 0;
  String? _selectedAnswer;
  AnswerFeedback _feedback = AnswerFeedback.none;
  bool _paused = false;

  /// Les 4 réponses de la question actuelle, générées une seule fois
  /// quand on arrive sur la question (pas à chaque frame).
  List<String> _currentAnswers = [];

  Timer? _ticker;
  Timer? _feedbackTimer;

  QuestionData get _question => _repository.questions[_index];

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTheme() async {
    try {
      await _repository.load();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _currentAnswers = _repository.generateAnswers(_question);
      });
      _startTicker();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  void _handleSelect(String answer) {
    if (_feedback != AnswerFeedback.none || _paused) return;

    final bool isCorrect = answer == _question.answer;

    setState(() {
      _selectedAnswer = answer;
      _feedback = isCorrect ? AnswerFeedback.correct : AnswerFeedback.wrong;
      if (isCorrect) {
        _score++;
      } else {
        _lives--;
      }
    });

    _feedbackTimer = Timer(_feedbackDuration, () {
      if (!mounted) return;

      final bool isGameOver = !isCorrect && _lives <= 0;
      final bool isLastQuestion = _index + 1 >= _repository.questions.length;

      if (isGameOver) {
        _showEndDialog(won: false);
        return;
      }
      if (isLastQuestion) {
        _showEndDialog(won: true);
        return;
      }

      setState(() {
        _index++;
        _selectedAnswer = null;
        _feedback = AnswerFeedback.none;
        // Nouvelle question -> nouveau tirage de mauvaises réponses.
        _currentAnswers = _repository.generateAnswers(_question);
      });
    });
  }

  void _restart() {
    _feedbackTimer?.cancel();
    setState(() {
      _index = 0;
      _lives = _maxLives;
      _score = 0;
      _elapsedSeconds = 0;
      _selectedAnswer = null;
      _feedback = AnswerFeedback.none;
      _paused = false;
      _currentAnswers = _repository.generateAnswers(_question);
    });
  }

  void _showEndDialog({required bool won}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EndScreen(
        won: won,
        score: _score,
        total: _repository.questions.length,
        onRestart: () {
          Navigator.of(context).pop();
          _restart();
        },
      ),
    );
  }

  AnswerState _stateFor(String option) {
    if (_selectedAnswer == null) return AnswerState.idle;
    if (option == _question.answer) return AnswerState.correct;
    if (option == _selectedAnswer) return AnswerState.wrong;
    return AnswerState.dim;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF08080E),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF08080E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Impossible de charger le thème "${widget.themeName}"',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _loadError!,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF08080E),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHud(),
                Expanded(
                  flex: 56,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ImageCard(
                      imagePath: _repository.imagePathFor(_question),
                      feedback: _feedback,
                    ),
                  ),
                ),
                Expanded(
                  flex: 44,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.4,
                      children: _currentAnswers
                          .map(
                            (option) => AnswerButton(
                              label: option,
                              state: _stateFor(option),
                              onTap: () => _handleSelect(option),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            if (_paused) _buildPauseOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHud() {
    final total = _repository.questions.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _paused = true),
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
          Row(
            children: List.generate(_maxLives, (i) {
              final bool filled = i < _lives;
              return Icon(
                filled ? Icons.favorite : Icons.favorite_border,
                color: filled ? const Color(0xFFE5383B) : const Color(0xFF6C6C8A),
                size: 20,
              );
            }),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _index / total,
                minHeight: 8,
                backgroundColor: const Color(0xFF1A1A2A),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF9B59F7)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_index + 1}/$total',
            style: const TextStyle(color: Color(0xFF6C6C8A), fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF12121D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x387B2FF7)),
            ),
            child: Text(
              _formatTime(_elapsedSeconds),
              style: const TextStyle(color: Color(0xFF9B59F7), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: const Color(0xE008080E),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF12121D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x387B2FF7)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pause',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _paused = false),
                  child: const Text('Reprendre'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _paused = false);
                    _restart();
                  },
                  child: const Text('Recommencer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndScreen extends StatelessWidget {
  const _EndScreen({
    required this.won,
    required this.score,
    required this.total,
    required this.onRestart,
  });

  final bool won;
  final int score;
  final int total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF08080E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(won ? '🏆' : '💔', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              won ? 'Partie terminée !' : 'Partie perdue',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '$score / $total',
              style: const TextStyle(color: Color(0xFF9B59F7), fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRestart,
                child: const Text('Rejouer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}