import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/pokeball_opening.dart';
import '../../../core/audio/audio_controller.dart';

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
    // Pre-carga del SFX para garantizar reproducción inmediata en dispositivo real.
    Future.microtask(() => AudioController.instance.preloadSfxAsset('audio/pokeball_sound.mp3'));
  }

  Future<void> _handleOpened() async {
    // Pequeña pausa después de la animación antes de navegar
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
          Center(
            child: PokeballOpening(
              size: 200,
              onOpened: _handleOpened,
              sfxVolume: 0.35, // volumen reducido
            ),
          ),
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
