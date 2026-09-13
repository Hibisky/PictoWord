import 'package:flutter/material.dart';

/// Page affichée au tout premier lancement de l'app.
/// Objectif : savoir immédiatement si l'app charge correctement
/// (base de données, assets, etc.) ou s'il y a un problème en amont.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

enum _LoadState { loading, success, error }

class _SplashScreenState extends State<SplashScreen> {
  _LoadState _state = _LoadState.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAppReady();
  }

  Future<void> _checkAppReady() async {
    try {
      // TODO: remplace ce délai par tes vraies vérifications, par ex :
      // - initialisation de la base (lib/database/app_database.dart)
      // - lecture d'un thème (features/themes/repository/theme_repository.dart)
      // - chargement d'une image test depuis assets/images
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      setState(() => _state = _LoadState.success);

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/game');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _LoadState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: _buildContent()));
  }

  Widget _buildContent() {
    switch (_state) {
      case _LoadState.loading:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de PictoWord...'),
          ],
        );
      case _LoadState.success:
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text('Application chargée avec succès'),
          ],
        );
      case _LoadState.error:
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Problème au démarrage'),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Erreur inconnue',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }
}
