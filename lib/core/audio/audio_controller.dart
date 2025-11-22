import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

/// Controlador de audio centralizado para gestionar la música de fondo y efectos de sonido
/// a través de las transiciones de rutas. Implementa conciencia del ciclo de vida para manejar
/// el paso de la aplicación a segundo plano y primer plano.
class AudioController with WidgetsBindingObserver {
  // Patrón singleton
  AudioController._();
  static final AudioController instance = AudioController._();

  // Instancias de reproductores de audio
  final AudioPlayer _bgm = AudioPlayer();
  final AudioPlayer _sfx = AudioPlayer();

  // Estado de inicialización
  bool _initialized = false;

  // Estado de la música de fondo
  String? _currentBgmAsset;
  double _bgmVolume = 0.0;
  bool _resumeBgmOnForeground = false;

  // Estado de los efectos de sonido
  double _sfxVolume = 1.0;
  bool _sfxIsPlaying = false;
  bool _isCrossfading = false;
  Duration? _sfxDuration;
  Duration _sfxPosition = Duration.zero;

  // Constantes de configuración de audio
  static const int _defaultFadeSteps = 10;
  static const int _crossfadeFadeSteps = 20;
  static const int _defaultSfxFallbackDelayMs = 900;
  static const String _assetPrefix = 'assets/';

  /// Inicializa el controlador de audio y configura los contextos de audio para
  /// la reproducción de música de fondo y efectos de sonido.
  Future<void> init() async {
    if (_initialized) return;

    WidgetsBinding.instance.addObserver(this);

    await _configureGlobalAudioContext();
    await _configureBgmPlayer();
    await _configureSfxPlayer();
    _setupSfxListeners();

    _initialized = true;
  }

  /// Configura el contexto de audio global para la aplicación
  Future<void> _configureGlobalAudioContext() async {
    await AudioPlayer.global.setAudioContext(
      _createAudioContext(
        androidUsage: AndroidUsageType.game,
        androidFocus: AndroidAudioFocus.gain,
      ),
    );
  }

  /// Configura el reproductor de música de fondo con reproducción en bucle habilitada
  Future<void> _configureBgmPlayer() async {
    await _bgm.setAudioContext(
      _createAudioContext(
        androidUsage: AndroidUsageType.media,
        androidFocus: AndroidAudioFocus.gain,
      ),
    );
    await _bgm.setReleaseMode(ReleaseMode.loop);
  }

  /// Configura el reproductor de efectos de sonido con foco de audio transitorio
  Future<void> _configureSfxPlayer() async {
    await _sfx.setAudioContext(
      _createAudioContext(
        androidUsage: AndroidUsageType.media,
        androidFocus: AndroidAudioFocus.gainTransient,
      ),
    );
    await _sfx.setReleaseMode(ReleaseMode.release);
  }

  /// Configura los listeners para los cambios de estado del reproductor de efectos de sonido
  void _setupSfxListeners() {
    _sfx.onPlayerStateChanged.listen((state) {
      _sfxIsPlaying = state == PlayerState.playing;
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _sfxIsPlaying = false;
        _sfxVolume = 0.0;
      }
    });
    _sfx.onDurationChanged.listen((d) => _sfxDuration = d);
    _sfx.onPositionChanged.listen((p) => _sfxPosition = p);
  }

  /// Crea un contexto de audio con la configuración especificada para Android e iOS
  AudioContext _createAudioContext({
    required AndroidUsageType androidUsage,
    required AndroidAudioFocus androidFocus,
  }) {
    return AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: androidUsage,
        audioFocus: androidFocus,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    );
  }

  /// Maneja los cambios de estado del ciclo de vida de la aplicación para pausar/reanudar la música de fondo
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _handleAppBackgrounded();
        break;
    }
  }

  /// Reanuda la música de fondo cuando la aplicación vuelve al primer plano
  void _handleAppResumed() {
    if (_resumeBgmOnForeground && _currentBgmAsset != null) {
      _bgm.resume();
    }
    _resumeBgmOnForeground = false;
  }

  /// Pausa la música de fondo cuando la aplicación pasa a segundo plano
  void _handleAppBackgrounded() {
    if (_isBgmPlaying) {
      _resumeBgmOnForeground = true;
      _bgm.pause();
    } else {
      _resumeBgmOnForeground = false;
    }
  }

  /// Verifica si la música de fondo está actualmente configurada
  bool get _isBgmPlaying => _currentBgmAsset != null;

  // API Pública: Música de Fondo

  /// Reproduce un asset de música de fondo con efecto de fade-in opcional.
  /// Si la misma pista ya está reproduciéndose, ajusta el volumen al nivel objetivo.
  ///
  /// [assetPath] - Ruta al asset de audio (ej: 'audio/bgm.mp3')
  /// [volume] - Nivel de volumen objetivo (0.0 a 1.0)
  /// [fadeIn] - Duración del efecto de fade-in
  Future<void> playBgmAsset(
    String assetPath, {
    double volume = 0.6,
    Duration fadeIn = const Duration(milliseconds: 500),
  }) async {
    await init();

    if (_currentBgmAsset == assetPath) {
      await _fadeVolume(_bgm, _bgmVolume, volume, fadeIn, isBgm: true);
      return;
    }

    _currentBgmAsset = assetPath;
    _bgmVolume = 0.0;
    await _bgm.setVolume(_bgmVolume);
    await _bgm.play(AssetSource(assetPath));
    await _fadeVolume(_bgm, _bgmVolume, volume, fadeIn, isBgm: true);
  }

  /// Hace crossfade a una nueva pista de música de fondo con transición de volumen suave.
  ///
  /// [assetPath] - Ruta al nuevo asset de audio
  /// [targetVolume] - Nivel de volumen objetivo para la nueva pista
  /// [duration] - Duración del efecto de crossfade
  Future<void> crossfadeToBgm(
    String assetPath, {
    double targetVolume = 0.6,
    Duration duration = const Duration(milliseconds: 900),
  }) async {
    await init();
    if (_isCrossfading) return;
    _isCrossfading = true;

    await _prepareCrossfadeTrack(assetPath);
    await _performCrossfade(targetVolume, duration);

    _isCrossfading = false;
  }

  /// Prepara la nueva pista para el crossfade estableciéndola a volumen cero
  Future<void> _prepareCrossfadeTrack(String assetPath) async {
    if (_currentBgmAsset != assetPath) {
      _currentBgmAsset = assetPath;
      _bgmVolume = 0.0;
      await _bgm.setVolume(_bgmVolume);
      await _bgm.play(AssetSource(assetPath));
    } else {
      await _bgm.setVolume(0.0);
      _bgmVolume = 0.0;
    }
  }

  /// Realiza el crossfade real aumentando gradualmente el volumen
  Future<void> _performCrossfade(double targetVolume, Duration duration) async {
    final stepDuration = Duration(
      milliseconds: (duration.inMilliseconds / _crossfadeFadeSteps).round(),
    );

    for (var i = 1; i <= _crossfadeFadeSteps; i++) {
      final t = i / _crossfadeFadeSteps;
      final curvedT = Curves.easeInOut.transform(t);

      _bgmVolume = targetVolume * curvedT;
      await _bgm.setVolume(_bgmVolume);

      if (i < _crossfadeFadeSteps) {
        await Future.delayed(stepDuration);
      }
    }
  }

  /// Pausa la música de fondo que está reproduciéndose actualmente
  Future<void> pauseBgm() async {
    if (_isBgmPlaying) {
      await _bgm.pause();
      _resumeBgmOnForeground = true;
    }
  }

  /// Reanuda la música de fondo pausada
  Future<void> resumeBgm() async {
    if (_isBgmPlaying) {
      await _bgm.resume();
      _resumeBgmOnForeground = false;
    }
  }

  /// Detiene la música de fondo y reinicia su estado
  Future<void> stopBgm() async {
    await _bgm.stop();
    _currentBgmAsset = null;
    _bgmVolume = 0.0;
    _resumeBgmOnForeground = false;
  }

  // API Pública: Efectos de Sonido

  /// Precarga un asset de efecto de sonido para reproducción inmediata.
  /// Útil para SFX críticos que necesitan reproducirse sin retraso.
  ///
  /// [assetPath] - Ruta al asset del efecto de sonido
  Future<void> preloadSfxAsset(String assetPath) async {
    await init();
    await _loadSfxSource(assetPath);
  }

  /// Reproduce un asset de efecto de sonido. Esto es fire-and-forget y no
  /// interrumpirá la música de fondo.
  ///
  /// [assetPath] - Ruta al asset del efecto de sonido
  /// [volume] - Volumen de reproducción (0.0 a 1.0)
  Future<void> playSfxAsset(String assetPath, {double volume = 1.0}) async {
    await init();
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfx.setVolume(_sfxVolume);
    await _playSfxSource(assetPath);
    _sfxIsPlaying = true;
  }

  /// Espera a que termine el efecto de sonido actual, luego inicia la música
  /// de fondo con un efecto de fade-in. Permite transiciones de audio suaves.
  ///
  /// [assetPath] - Ruta al asset de música de fondo
  /// [targetVolume] - Volumen objetivo para la música de fondo
  /// [fadeIn] - Duración del efecto de fade-in
  /// [overlap] - Cuánto solapar el final del SFX con el inicio del BGM
  Future<void> startBgmAfterSfx(
    String assetPath, {
    double targetVolume = 0.55,
    Duration fadeIn = const Duration(milliseconds: 1200),
    Duration overlap = Duration.zero,
  }) async {
    await init();

    if (_sfxIsPlaying) {
      await _waitForSfxCompletion(overlap);
    }

    await playBgmAsset(assetPath, volume: targetVolume, fadeIn: fadeIn);
  }

  /// Espera a que se complete el efecto de sonido, contabilizando el solapamiento
  Future<void> _waitForSfxCompletion(Duration overlap) async {
    if (_sfxDuration != null) {
      final remaining = _sfxDuration! - _sfxPosition;
      final wait = remaining - overlap;
      final delay = wait.isNegative ? Duration.zero : wait;
      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }
    } else {
      await Future.delayed(
        Duration(milliseconds: _defaultSfxFallbackDelayMs),
      );
    }
  }

  // Métodos Auxiliares Privados

  /// Carga una fuente de efecto de sonido con resolución de ruta de respaldo
  Future<void> _loadSfxSource(String assetPath) async {
    try {
      await _sfx.setSource(AssetSource(assetPath));
    } catch (_) {
      final fallback = _resolveFallbackPath(assetPath);
      try {
        await _sfx.setSource(AssetSource(fallback));
      } catch (e) {
        _logError('Error preloading SFX: $assetPath -> $e');
      }
    }
  }

  /// Reproduce una fuente de efecto de sonido con resolución de ruta de respaldo
  Future<void> _playSfxSource(String assetPath) async {
    try {
      await _sfx.play(AssetSource(assetPath));
    } catch (e) {
      final fallback = _resolveFallbackPath(assetPath);
      try {
        await _sfx.play(AssetSource(fallback));
      } catch (e2) {
        _logError(
          'Error playing SFX: $assetPath with fallback $fallback -> $e / $e2',
        );
      }
    }
  }

  /// Resuelve una ruta de asset de respaldo agregando el prefijo 'assets/' si falta
  String _resolveFallbackPath(String assetPath) {
    return assetPath.startsWith(_assetPrefix)
        ? assetPath
        : '$_assetPrefix$assetPath';
  }

  /// Aplica un efecto de desvanecimiento de volumen a un reproductor de audio
  Future<void> _fadeVolume(
    AudioPlayer player,
    double from,
    double to,
    Duration duration, {
    bool isBgm = false,
  }) async {
    if (duration.inMilliseconds <= 0) {
      final targetVolume = to;
      if (isBgm) _bgmVolume = targetVolume;
      await player.setVolume(targetVolume);
      return;
    }

    final stepDuration = Duration(
      milliseconds: (duration.inMilliseconds / _defaultFadeSteps).round(),
    );

    for (var i = 1; i <= _defaultFadeSteps; i++) {
      final t = i / _defaultFadeSteps;
      final volume = from + (to - from) * t;

      if (isBgm) _bgmVolume = volume;
      await player.setVolume(volume);

      if (i < _defaultFadeSteps) {
        await Future.delayed(stepDuration);
      }
    }
  }

  /// Registra un mensaje de error (puede ser reemplazado con un sistema de logging apropiado)
  void _logError(String message) {
    // ignore: avoid_print
    print('[AudioController] $message');
  }
}
