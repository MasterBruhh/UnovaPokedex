import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../../core/widgets/yellow_grid_background.dart';
import '../../theme/trivia_colors.dart';
import '../providers/trivia_provider.dart';

class TriviaHomePage extends ConsumerWidget {
  const TriviaHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Leer el idioma actual del provider
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF8B7500),
      body: Stack(
        children: [
          const Positioned.fill(child: YellowGridBackground()),
          SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fila superior: Botón Atrás y Selector de Idioma
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 28,
                    ),

                    // BOTONES DE IDIOMA
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LanguageButton(
                            label: 'ES',
                            isSelected: currentLocale.languageCode == 'es',
                            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('es')),
                          ),
                          _LanguageButton(
                            label: 'EN',
                            isSelected: currentLocale.languageCode == 'en',
                            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Ícono
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.catching_pokemon,
                    size: 100,
                    color: TriviaColors.accent,
                  ),
                ),
                const SizedBox(height: 32),

                // Títulos
                const Text(
                  'Pokémon',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.triviaTitle, // TRADUCIDO
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: TriviaColors.accent,
                    letterSpacing: 8,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subtítulo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.triviaSubtitle, // TRADUCIDO
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(),

                // Modos
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildModeItem(
                        Icons.visibility_off,
                        l10n.modeSilhouetteTitle, // TRADUCIDO
                        l10n.modeSilhouetteSubtitle,
                      ),
                      const SizedBox(height: 12),
                      _buildModeItem(
                        Icons.description,
                        l10n.modeDescriptionTitle, // TRADUCIDO
                        l10n.modeDescriptionSubtitle,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Botón Iniciar
                Semantics(
                  label: l10n.startGame,
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.pushNamed('trivia_game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TriviaColors.accent,
                        foregroundColor: TriviaColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            l10n.startGame,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Botón Ver Ranking
                Semantics(
                  label: l10n.viewRanking,
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.pushNamed('trivia_ranking'),
                      icon: const Icon(Icons.leaderboard, size: 24),
                      label: Text(
                        l10n.viewRanking,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildModeItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget auxiliar para los botones de idioma
class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? TriviaColors.textPrimary : Colors.white,
          ),
        ),
      ),
    );
  }
}