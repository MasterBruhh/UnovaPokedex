// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get triviaTitle => 'TRIVIA';

  @override
  String get triviaSubtitle => '¡Pon a prueba tu conocimiento Pokémon!';

  @override
  String get modeSilhouetteTitle => '¿Quién es ese Pokémon?';

  @override
  String get modeSilhouetteSubtitle => 'Adivina por la silueta';

  @override
  String get modeDescriptionTitle => 'Desafío de descripción';

  @override
  String get modeDescriptionSubtitle => 'Identifica por la entrada del Pokédex';

  @override
  String get startGame => 'INICIAR JUEGO';

  @override
  String get loadingQuestion => 'Cargando pregunta...';

  @override
  String get correctAnswer => '¡Correcto!';

  @override
  String get wrongAnswer => '¡Incorrecto!';

  @override
  String get exitGameTitle => '¿Salir del juego?';

  @override
  String get exitGameContent =>
      '¿Estás seguro de que quieres salir? Tu progreso se perderá.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get exit => 'Salir';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get yourScore => 'Tu puntuación';

  @override
  String get playAgain => 'JUGAR DE NUEVO';

  @override
  String get mainMenu => 'MENÚ PRINCIPAL';

  @override
  String get scoreMsg0 =>
      '¡No te rindas! Todo Maestro Pokémon empezó en algún lugar.';

  @override
  String get scoreMsgLow =>
      '¡Buen comienzo! ¡Sigue entrenando para convertirte en Maestro Pokémon!';

  @override
  String get scoreMsgMid => '¡Buen trabajo! ¡Estás en camino a la grandeza!';

  @override
  String get scoreMsgHigh =>
      '¡Impresionante! ¡Realmente conoces a tus Pokémon!';

  @override
  String get scoreMsgMax => '¡Increíble! ¡Eres un verdadero Maestro Pokémon!';

  @override
  String get backButtonLabel => 'Regresar';

  @override
  String get silhouetteLabel => 'Silueta de Pokémon';

  @override
  String get revealedLabel => 'Imagen de Pokémon revelada';
}
