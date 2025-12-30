import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'pokemon_sprite_utils.dart';

/// Servicio para cachear sprites de Pokémon localmente
/// Permite funcionamiento offline de la lista de favoritos
class SpriteCacheService {
  SpriteCacheService._();
  static final SpriteCacheService instance = SpriteCacheService._();

  String? _cacheDir;

  /// Obtiene el directorio de caché para sprites
  Future<String> get cacheDirectory async {
    if (_cacheDir != null) return _cacheDir!;
    
    final appDir = await getApplicationDocumentsDirectory();
    final spriteDir = Directory('${appDir.path}/pokemon_sprites');
    
    if (!await spriteDir.exists()) {
      await spriteDir.create(recursive: true);
    }
    
    _cacheDir = spriteDir.path;
    return _cacheDir!;
  }

  /// Nombre del archivo para el sprite normal
  String _getNormalSpriteName(int pokemonId) => 'sprite_$pokemonId.png';

  /// Nombre del archivo para el sprite shiny
  String _getShinySpriteName(int pokemonId) => 'sprite_shiny_$pokemonId.png';

  /// Obtiene la ruta local del sprite normal
  Future<String> getLocalSpritePath(int pokemonId) async {
    final dir = await cacheDirectory;
    return '$dir/${_getNormalSpriteName(pokemonId)}';
  }

  /// Obtiene la ruta local del sprite shiny
  Future<String> getLocalShinySpritePath(int pokemonId) async {
    final dir = await cacheDirectory;
    return '$dir/${_getShinySpriteName(pokemonId)}';
  }

  /// Verifica si un sprite está cacheado localmente
  Future<bool> isSpriteCached(int pokemonId) async {
    final path = await getLocalSpritePath(pokemonId);
    return File(path).exists();
  }

  /// Verifica si un sprite shiny está cacheado localmente
  Future<bool> isShinySpriteCached(int pokemonId) async {
    final path = await getLocalShinySpritePath(pokemonId);
    return File(path).exists();
  }

  /// Descarga y cachea el sprite normal de un Pokémon
  /// Retorna la ruta local del archivo guardado, o null si falla
  Future<String?> cacheSprite(int pokemonId) async {
    try {
      final localPath = await getLocalSpritePath(pokemonId);
      final file = File(localPath);
      
      // Si ya existe, retornar la ruta
      if (await file.exists()) {
        return localPath;
      }

      // Descargar el sprite
      final url = PokemonSpriteUtils.getSpriteUrl(pokemonId);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return localPath;
      }
      
      return null;
    } catch (e) {
      print('Error cacheando sprite para Pokémon $pokemonId: $e');
      return null;
    }
  }

  /// Descarga y cachea el sprite shiny de un Pokémon
  /// Retorna la ruta local del archivo guardado, o null si falla
  Future<String?> cacheShinySprite(int pokemonId) async {
    try {
      final localPath = await getLocalShinySpritePath(pokemonId);
      final file = File(localPath);
      
      // Si ya existe, retornar la ruta
      if (await file.exists()) {
        return localPath;
      }

      // Descargar el sprite shiny
      final url = PokemonSpriteUtils.getShinySpriteUrl(pokemonId);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return localPath;
      }
      
      return null;
    } catch (e) {
      print('Error cacheando sprite shiny para Pokémon $pokemonId: $e');
      return null;
    }
  }

  /// Cachea ambos sprites (normal y shiny) de un Pokémon
  /// Retorna un mapa con las rutas locales
  Future<Map<String, String?>> cacheAllSprites(int pokemonId) async {
    final results = await Future.wait([
      cacheSprite(pokemonId),
      cacheShinySprite(pokemonId),
    ]);
    
    return {
      'sprite': results[0],
      'shiny': results[1],
    };
  }

  /// Elimina los sprites cacheados de un Pokémon
  Future<void> deleteSprites(int pokemonId) async {
    try {
      final normalPath = await getLocalSpritePath(pokemonId);
      final shinyPath = await getLocalShinySpritePath(pokemonId);
      
      final normalFile = File(normalPath);
      final shinyFile = File(shinyPath);
      
      if (await normalFile.exists()) {
        await normalFile.delete();
      }
      if (await shinyFile.exists()) {
        await shinyFile.delete();
      }
    } catch (e) {
      print('Error eliminando sprites para Pokémon $pokemonId: $e');
    }
  }

  /// Carga los bytes de un sprite cacheado
  Future<Uint8List?> loadCachedSprite(int pokemonId) async {
    try {
      final path = await getLocalSpritePath(pokemonId);
      final file = File(path);
      
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Carga los bytes de un sprite shiny cacheado
  Future<Uint8List?> loadCachedShinySprite(int pokemonId) async {
    try {
      final path = await getLocalShinySpritePath(pokemonId);
      final file = File(path);
      
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
