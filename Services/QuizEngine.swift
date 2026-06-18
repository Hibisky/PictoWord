// Services/QuizEngine.swift
// Cerveau du jeu : sélectionne les 10 questions d'une session
// et génère les distracteurs aléatoires pour chaque question.

import Foundation

// ─── GameQuestion ────────────────────────────────────────
// Struct prête à l'emploi pour GameView :
// contient la question + les 4 mots mélangés.

struct GameQuestion: Identifiable {
    let id: String                // = question.id
    let question: Question        // données brutes
    let choices: [String]         // 4 mots dans un ordre aléatoire

    var correctWord: String  { question.correctWord }
    var imageName: String    { question.imageName }
    var hint: String         { question.hint }
    var funFact: String      { question.funFact }
}

// ─── QuizEngine ──────────────────────────────────────────

final class QuizEngine {

    /// Construit une session complète de `count` GameQuestions
    /// à partir de toutes les questions disponibles pour un niveau.
    ///
    /// - Parameters:
    ///   - questions : toutes les questions du niveau choisi
    ///   - count     : nombre de questions par session (défaut 10)
    /// - Returns: tableau de GameQuestion prêtes à jouer
    func buildSession(from questions: [Question], count: Int = 10) -> [GameQuestion] {

        // 1. Sécurité : on ne peut pas tirer plus que ce qu'on a
        let sessionCount = min(count, questions.count)

        // 2. Tirer `sessionCount` questions au hasard (sans répétition)
        let picked = questions.shuffled().prefix(sessionCount)

        // 3. Pour chaque question, construire sa GameQuestion avec distracteurs
        return picked.map { question in
            buildGameQuestion(for: question, allQuestions: questions)
        }
    }

    /// Génère une GameQuestion : correct word + 3 distracteurs mélangés.
    func buildGameQuestion(for question: Question, allQuestions: [Question]) -> GameQuestion {

        // 1. Obtenir le pool de distracteurs candidats
        let pool = distractorPool(for: question, allQuestions: allQuestions)

        // 2. Piocher 3 mots au hasard dans le pool
        let distractors = pool
            .shuffled()
            .prefix(3)
            .map { $0.correctWord }

        // 3. Mélanger le mot correct avec les 3 distracteurs
        let choices = ([question.correctWord] + distractors).shuffled()

        return GameQuestion(
            id: question.id,
            question: question,
            choices: choices
        )
    }

    // Stratégie de sélection (par priorité) :
    //   1. Même thème ET même niveau          → distracteurs très cohérents
    //   2. Même thème (tout niveau)           → fallback si niveau trop petit
    //   3. Tout le jeu (tout thème/niveau)    → dernier recours
    //
    // On exclut toujours la question courante pour éviter
    // d'avoir le bon mot en doublon.

    func distractorPool(for question: Question, allQuestions: [Question]) -> [Question] {

        // Exclure la question courante dans tous les cas
        let others = allQuestions.filter { $0.id != question.id }

        // ── Priorité 1 : même thème + même niveau ──────
        let sameThemeAndLevel = others.filter {
            $0.theme == question.theme && $0.level == question.level
        }
        if sameThemeAndLevel.count >= 3 {
            return sameThemeAndLevel
        }

        // ── Priorité 2 : même thème (tout niveau) ──────
        let sameTheme = others.filter { $0.theme == question.theme }
        if sameTheme.count >= 3 {
            return sameTheme
        }

        // ── Priorité 3 : fallback global ────────────────
        // Si le thème est trop petit (< 4 questions au total),
        // on pioche dans tout le catalogue.
        return others
    }

    /// Vérifie si le mot choisi est correct
    func isCorrect(choice: String, for gameQuestion: GameQuestion) -> Bool {
        choice == gameQuestion.correctWord
    }

    /// Calcule le score final d'une session
    /// - Parameter results : tableau de Bool (true = bonne réponse)
    func calculateScore(results: [Bool]) -> Int {
        results.filter { $0 }.count
    }

    /// Calcule le pourcentage de réussite
    func calculatePercentage(score: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return (Double(score) / Double(total)) * 100
    }
}