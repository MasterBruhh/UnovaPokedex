import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @triviaTitle.
  ///
  /// In es, this message translates to:
  /// **'TRIVIA'**
  String get triviaTitle;

  /// No description provided for @triviaSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¡Pon a prueba tu conocimiento Pokémon!'**
  String get triviaSubtitle;

  /// No description provided for @modeSilhouetteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quién es ese Pokémon?'**
  String get modeSilhouetteTitle;

  /// No description provided for @modeSilhouetteSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Adivina por la silueta'**
  String get modeSilhouetteSubtitle;

  /// No description provided for @modeDescriptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Desafío de descripción'**
  String get modeDescriptionTitle;

  /// No description provided for @modeDescriptionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Identifica por la entrada del Pokédex'**
  String get modeDescriptionSubtitle;

  /// No description provided for @startGame.
  ///
  /// In es, this message translates to:
  /// **'INICIAR JUEGO'**
  String get startGame;

  /// No description provided for @loadingQuestion.
  ///
  /// In es, this message translates to:
  /// **'Cargando pregunta...'**
  String get loadingQuestion;

  /// No description provided for @correctAnswer.
  ///
  /// In es, this message translates to:
  /// **'¡Correcto!'**
  String get correctAnswer;

  /// No description provided for @wrongAnswer.
  ///
  /// In es, this message translates to:
  /// **'¡Incorrecto!'**
  String get wrongAnswer;

  /// No description provided for @exitGameTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Salir del juego?'**
  String get exitGameTitle;

  /// No description provided for @exitGameContent.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres salir? Tu progreso se perderá.'**
  String get exitGameContent;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get exit;

  /// No description provided for @gameOver.
  ///
  /// In es, this message translates to:
  /// **'GAME OVER'**
  String get gameOver;

  /// No description provided for @yourScore.
  ///
  /// In es, this message translates to:
  /// **'Tu puntuación'**
  String get yourScore;

  /// No description provided for @playAgain.
  ///
  /// In es, this message translates to:
  /// **'JUGAR DE NUEVO'**
  String get playAgain;

  /// No description provided for @mainMenu.
  ///
  /// In es, this message translates to:
  /// **'MENÚ PRINCIPAL'**
  String get mainMenu;

  /// No description provided for @scoreMsg0.
  ///
  /// In es, this message translates to:
  /// **'¡No te rindas! Todo Maestro Pokémon empezó en algún lugar.'**
  String get scoreMsg0;

  /// No description provided for @scoreMsgLow.
  ///
  /// In es, this message translates to:
  /// **'¡Buen comienzo! ¡Sigue entrenando para convertirte en Maestro Pokémon!'**
  String get scoreMsgLow;

  /// No description provided for @scoreMsgMid.
  ///
  /// In es, this message translates to:
  /// **'¡Buen trabajo! ¡Estás en camino a la grandeza!'**
  String get scoreMsgMid;

  /// No description provided for @scoreMsgHigh.
  ///
  /// In es, this message translates to:
  /// **'¡Impresionante! ¡Realmente conoces a tus Pokémon!'**
  String get scoreMsgHigh;

  /// No description provided for @scoreMsgMax.
  ///
  /// In es, this message translates to:
  /// **'¡Increíble! ¡Eres un verdadero Maestro Pokémon!'**
  String get scoreMsgMax;

  /// No description provided for @backButtonLabel.
  ///
  /// In es, this message translates to:
  /// **'Regresar'**
  String get backButtonLabel;

  /// No description provided for @silhouetteLabel.
  ///
  /// In es, this message translates to:
  /// **'Silueta de Pokémon'**
  String get silhouetteLabel;

  /// No description provided for @revealedLabel.
  ///
  /// In es, this message translates to:
  /// **'Imagen de Pokémon revelada'**
  String get revealedLabel;

  /// No description provided for @timeUp.
  ///
  /// In es, this message translates to:
  /// **'¡Tiempo agotado!'**
  String get timeUp;

  /// No description provided for @secondsRemaining.
  ///
  /// In es, this message translates to:
  /// **'{seconds} segundos restantes'**
  String secondsRemaining(Object seconds);

  /// No description provided for @rankingAndAchievements.
  ///
  /// In es, this message translates to:
  /// **'Ranking y Logros'**
  String get rankingAndAchievements;

  /// No description provided for @rankingTab.
  ///
  /// In es, this message translates to:
  /// **'Ranking'**
  String get rankingTab;

  /// No description provided for @achievementsTab.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get achievementsTab;

  /// No description provided for @bestScore.
  ///
  /// In es, this message translates to:
  /// **'Mejor Puntuación'**
  String get bestScore;

  /// No description provided for @bestScoreLabel.
  ///
  /// In es, this message translates to:
  /// **'Tu mejor puntuación histórica'**
  String get bestScoreLabel;

  /// No description provided for @noRankingYet.
  ///
  /// In es, this message translates to:
  /// **'Sin registros aún'**
  String get noRankingYet;

  /// No description provided for @playToSeeRanking.
  ///
  /// In es, this message translates to:
  /// **'¡Juega para ver tu ranking!'**
  String get playToSeeRanking;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In es, this message translates to:
  /// **'desbloqueados'**
  String get achievementsUnlocked;

  /// No description provided for @newAchievement.
  ///
  /// In es, this message translates to:
  /// **'¡Nuevo Logro!'**
  String get newAchievement;

  /// No description provided for @continueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @viewRanking.
  ///
  /// In es, this message translates to:
  /// **'Ver Ranking'**
  String get viewRanking;

  /// No description provided for @achievementFirstGame.
  ///
  /// In es, this message translates to:
  /// **'Primera Partida'**
  String get achievementFirstGame;

  /// No description provided for @achievementFirstGameDesc.
  ///
  /// In es, this message translates to:
  /// **'¡Jugaste tu primera partida de trivia!'**
  String get achievementFirstGameDesc;

  /// No description provided for @achievementScore5.
  ///
  /// In es, this message translates to:
  /// **'Entrenador Novato'**
  String get achievementScore5;

  /// No description provided for @achievementScore5Desc.
  ///
  /// In es, this message translates to:
  /// **'Alcanza 5 puntos en una partida'**
  String get achievementScore5Desc;

  /// No description provided for @achievementScore10.
  ///
  /// In es, this message translates to:
  /// **'Conocedor Pokémon'**
  String get achievementScore10;

  /// No description provided for @achievementScore10Desc.
  ///
  /// In es, this message translates to:
  /// **'Alcanza 10 puntos en una partida'**
  String get achievementScore10Desc;

  /// No description provided for @achievementScore25.
  ///
  /// In es, this message translates to:
  /// **'Experto Pokémon'**
  String get achievementScore25;

  /// No description provided for @achievementScore25Desc.
  ///
  /// In es, this message translates to:
  /// **'Alcanza 25 puntos en una partida'**
  String get achievementScore25Desc;

  /// No description provided for @achievementScore50.
  ///
  /// In es, this message translates to:
  /// **'Maestro Pokémon'**
  String get achievementScore50;

  /// No description provided for @achievementScore50Desc.
  ///
  /// In es, this message translates to:
  /// **'Alcanza 50 puntos en una partida'**
  String get achievementScore50Desc;

  /// No description provided for @achievementScore100.
  ///
  /// In es, this message translates to:
  /// **'Leyenda Pokémon'**
  String get achievementScore100;

  /// No description provided for @achievementScore100Desc.
  ///
  /// In es, this message translates to:
  /// **'Alcanza 100 puntos en una partida'**
  String get achievementScore100Desc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
