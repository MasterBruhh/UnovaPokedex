import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/audio/audio_controller.dart';
import '../../../../core/config/app_constants.dart';
import '../widgets/pokeball_opening.dart';

/// Pantalla de splash con animación de apertura de Pokéball
class PokeballSplashPage extends StatefulWidget {
  const PokeballSplashPage({super.key});

  @override
  State<PokeballSplashPage> createState() => _PokeballSplashPageState();
}

class _PokeballSplashPageState extends State<PokeballSplashPage> {
  bool _hintVisible = true;

  @override
  void initState() {
    super.initState();
    // Precargar SFX para reproducción instantánea en dispositivos reales
    Future.microtask(() => AudioController.instance
        .preloadSfxAsset(AppConstants.pokeballSfxPath));
  }

  Future<void> _handleOpened() async {
    // Pequeño retraso después de la animación antes de navegar
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    context.goNamed('menu');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Gradiente de fondo
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE5E5), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Animación de Pokéball
          Center(
            child: PokeballOpening(
              size: 200,
              onOpened: _handleOpened,
              sfxVolume: 0.35,
            ),
          ),

          // Texto de pista
          Positioned(
            bottom: 48,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _hintVisible ? 1 : 0,
              child: GestureDetector(
                onTap: () => setState(() => _hintVisible = !_hintVisible),
                child: Text(
                  'Toca la Pokéball',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

