import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

// Controlador de audio centralizado para mantener los sonidos y la música activos a través de las rutas.
class AudioController with WidgetsBindingObserver {
  AudioController._();
  static final AudioController instance = AudioController._();

  final AudioPlayer _bgm = AudioPlayer();
  final AudioPlayer _sfx = AudioPlayer();

  bool _initialized = false;
  String? _currentBgmAsset;
  double _bgmVolume = 0.0; // Seguimiento del volumen actual de BGM. (BGM = música de fondo)
  bool _resumeBgmOnForeground = false; // reanudar solo si estaba sonando

  // Estado SFX para poder desvanecerlo correctamente
  double _sfxVolume = 1.0;
  bool _sfxIsPlaying = false;
  bool _isCrossfading = false;
  Duration? _sfxDuration; // duración conocida del SFX actual
  Duration _sfxPosition = Duration.zero; // posición actual del SFX

  Future<void> init() async {
    if (_initialized) return;

    // Registrar observador del ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);

    // Conservadores globales por defecto.
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );

    // Configuracion del reproductor de musica de fondo: enfoque musical estable.
    await _bgm.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    await _bgm.setReleaseMode(ReleaseMode.loop);

    // Configuración SFX: usar stream de música + foco transitorio para alta compatibilidad.
    await _sfx.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    await _sfx.setReleaseMode(ReleaseMode.release);

    // Escuchar el estado del SFX para saber si está sonando y poder desvanecerlo
    _sfx.onPlayerStateChanged.listen((state) {
      _sfxIsPlaying = state == PlayerState.playing;
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        _sfxIsPlaying = false;
        _sfxVolume = 0.0;
      }
    });
    _sfx.onDurationChanged.listen((d) => _sfxDuration = d);
    _sfx.onPositionChanged.listen((p) => _sfxPosition = p);

    _initialized = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_resumeBgmOnForeground && _currentBgmAsset != null) {
          _bgm.resume();
        }
        _resumeBgmOnForeground = false;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden: // Flutter 3.13+ (oculta en background en algunas plataformas)
        if (_currentBgmOn()) {
          _resumeBgmOnForeground = true;
          _bgm.pause();
        } else {
          _resumeBgmOnForeground = false;
        }
        break;
    }
  }

  bool _currentBgmOn() => _currentBgmAsset != null;

  Future<void> playBgmAsset(String assetPath, {double volume = 0.6, Duration fadeIn = const Duration(milliseconds: 500)}) async {
    await init();

    // En el caso de que la misma pista ya esté establecida, asegúrese del volumen (opcionalmente desvanecerse al nuevo volumen).
    if (_currentBgmAsset == assetPath) {
      await _fadeVolume(_bgm, _bgmVolume, volume, fadeIn, isBgm: true);
      return;
    }

    _currentBgmAsset = assetPath;

    // Inicio silencioso y luego desvanecerse para evitar enmascarar los SFX.
    _bgmVolume = 0.0;
    await _bgm.setVolume(_bgmVolume);
    await _bgm.play(AssetSource(assetPath));
    await _fadeVolume(_bgm, _bgmVolume, volume, fadeIn, isBgm: true);
  }

  Future<void> crossfadeToBgm(String assetPath, {double targetVolume = 0.6, Duration duration = const Duration(milliseconds: 900)}) async {
    await init();
    if (_isCrossfading) return;
    _isCrossfading = true;

    // Arranca o prepara el BGM al volumen 0
    if (_currentBgmAsset != assetPath) {
      _currentBgmAsset = assetPath;
      _bgmVolume = 0.0;
      await _bgm.setVolume(_bgmVolume);
      await _bgm.play(AssetSource(assetPath));
    } else {
      // misma pista: baja a 0 para hacer crossfade limpio
      await _bgm.setVolume(0.0);
      _bgmVolume = 0.0;
    }

    // Solo sube el BGM; NO toques el SFX (deja que termine naturalmente)
    const steps = 20; // Más pasos para mayor suavidad
    final stepDuration = Duration(milliseconds: (duration.inMilliseconds / steps).round());
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      // Curva más suave para el crossfade
      final ct = Curves.easeInOut.transform(t);

      // Sube BGM gradualmente
      _bgmVolume = targetVolume * ct;
      await _bgm.setVolume(_bgmVolume);

      if (i < steps) {
        await Future.delayed(stepDuration);
      }
    }

    _isCrossfading = false;
  }

  Future<void> pauseBgm() async {
    if (_currentBgmOn()) {
      await _bgm.pause();
      _resumeBgmOnForeground = true;
    }
  }

  Future<void> resumeBgm() async {
    if (_currentBgmOn()) {
      await _bgm.resume();
      _resumeBgmOnForeground = false;
    }
  }

  Future<void> stopBgm() async {
    await _bgm.stop();
    _currentBgmAsset = null;
    _bgmVolume = 0.0;
    _resumeBgmOnForeground = false;
  }

  // Prepara el SFX para reproducción inmediata (carga el asset en el player).
  Future<void> preloadSfxAsset(String assetPath) async {
    await init();
    try {
      await _sfx.setSource(AssetSource(assetPath));
    } catch (_) {
      final fallback = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
      try {
        await _sfx.setSource(AssetSource(fallback));
      } catch (e2) {
        // ignore: avoid_print
        print('[AudioController] Error preloading SFX: $assetPath -> $e2');
      }
    }
  }

  // Fire-and-forget SFX. No interrumpirá la música de fondo.
  Future<void> playSfxAsset(String assetPath, {double volume = 1.0}) async {
    try {
      await init();
      _sfxVolume = volume.clamp(0.0, 1.0);
      await _sfx.setVolume(_sfxVolume);
      // ignore: avoid_print
      print('[AudioController] Play SFX request: $assetPath');
      await _sfx.play(AssetSource(assetPath));
      _sfxIsPlaying = true;
    } catch (e) {
      final fallback = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
      try {
        await _sfx.play(AssetSource(fallback));
        _sfxIsPlaying = true;
      } catch (e2) {
        // ignore: avoid_print
        print('[AudioController] Error reproduciendo SFX: $assetPath y fallback $fallback -> $e / $e2');
      }
    }
  }

  // Espera a que termine el SFX actual (o casi) y luego inicia el BGM con fade-in.
  Future<void> startBgmAfterSfx(
    String assetPath, {
    double targetVolume = 0.55,
    Duration fadeIn = const Duration(milliseconds: 1200),
    Duration overlap = Duration.zero, // si quieres solapar un poco al final del SFX
  }) async {
    await init();

    if (_sfxIsPlaying) {
      if (_sfxDuration != null) {
        final remaining = _sfxDuration! - _sfxPosition;
        final wait = remaining - overlap;
        final delay = wait.isNegative ? Duration.zero : wait;
        if (delay > Duration.zero) {
          await Future.delayed(delay);
        }
      } else {
        // fallback genérico si no tenemos duración
        await Future.delayed(const Duration(milliseconds: 900));
      }
    }

    // Cuando llegamos aquí, el SFX ya terminó (o estamos en el tramo final
    // si se pidió un pequeño solape). Inicia el BGM con fade-in.
    await playBgmAsset(assetPath, volume: targetVolume, fadeIn: fadeIn);
  }

  Future<void> _fadeVolume(
    AudioPlayer player,
    double from,
    double to,
    Duration duration, {
    bool isBgm = false,
  }) async {
    const steps = 10;
    if (duration.inMilliseconds <= 0) {
      final v = to;
      if (isBgm) {
        _bgmVolume = v;
      }
      await player.setVolume(v);
      return;
    }
    final stepDuration = Duration(milliseconds: (duration.inMilliseconds / steps).round());
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final v = from + (to - from) * t;
      if (isBgm) {
        _bgmVolume = v;
      }
      await player.setVolume(v);
      if (i < steps) {
        await Future.delayed(stepDuration);
      }
    }
  }
}
