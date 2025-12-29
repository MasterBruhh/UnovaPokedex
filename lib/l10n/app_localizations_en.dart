// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get triviaTitle => 'TRIVIA';

  @override
  String get triviaSubtitle => 'Test your Pokémon knowledge!';

  @override
  String get modeSilhouetteTitle => 'Who\'s that Pokémon?';

  @override
  String get modeSilhouetteSubtitle => 'Guess from the silhouette';

  @override
  String get modeDescriptionTitle => 'Description Challenge';

  @override
  String get modeDescriptionSubtitle => 'Identify by Pokédex entry';

  @override
  String get startGame => 'START GAME';

  @override
  String get loadingQuestion => 'Loading question...';

  @override
  String get correctAnswer => 'Correct!';

  @override
  String get wrongAnswer => 'Wrong!';

  @override
  String get exitGameTitle => 'Quit Game?';

  @override
  String get exitGameContent =>
      'Are you sure you want to quit? Progress will be lost.';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Quit';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get yourScore => 'Your Score';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get mainMenu => 'MAIN MENU';

  @override
  String get scoreMsg0 =>
      'Don\'t give up! Every Pokémon Master started somewhere.';

  @override
  String get scoreMsgLow =>
      'Great start! Keep training to become a Pokémon Master!';

  @override
  String get scoreMsgMid => 'Good job! You are on your way to greatness!';

  @override
  String get scoreMsgHigh => 'Impressive! You really know your Pokémon!';

  @override
  String get scoreMsgMax => 'Incredible! You are a true Pokémon Master!';

  @override
  String get backButtonLabel => 'Back';

  @override
  String get silhouetteLabel => 'Pokémon silhouette';

  @override
  String get revealedLabel => 'Revealed Pokémon image';
}
