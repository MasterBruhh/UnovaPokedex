import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareUtils {
  /// Captura el widget envuelto en un RepaintBoundary con el [globalKey] dado,
  /// lo guarda como una imagen PNG temporal y abre el diálogo de compartir.
  static Future<void> captureAndShareWidget({
    required GlobalKey globalKey,
    required String fileName,
    String? text,
  }) async {
    try {
      // 1. Encontrar el objeto de renderizado (el widget en pantalla)
      RenderRepaintBoundary boundary =
      globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // 2. Convertirlo a una imagen de Dart UI (con alta resolución)
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // 3. Convertir la imagen a bytes PNG
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Error al generar la imagen');
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // 4. Obtener el directorio temporal del dispositivo
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/$fileName.png';
      final imageFile = File(imagePath);

      // 5. Guardar los bytes en el archivo
      await imageFile.writeAsBytes(pngBytes);

      // 6. Compartir el archivo usando share_plus
      final xFile = XFile(imagePath);
      await Share.shareXFiles([xFile], text: text);

    } catch (e) {
      debugPrint('Error al capturar o compartir: $e');
      // Aquí podrías mostrar un SnackBar de error si lo deseas
    }
  }
}