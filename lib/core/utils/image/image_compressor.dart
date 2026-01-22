import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../logger.dart';

class ImageCompressor {
  static const int _maxDimension = 1024;
  static const int _quality = 80;

  /// Compresses an image file to a maximum dimension and quality.
  /// Returns the compressed [File] or null if compression fails.
  static Future<File?> compressImage(File file) async {
    try {
      final String fileName = p.basename(file.path);
      final String fileExt = p.extension(file.path);
      final String tempName =
          '${p.basenameWithoutExtension(fileName)}_compressed$fileExt';

      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = p.join(tempDir.path, tempName);

      // Verify file exists
      if (!await file.exists()) {
        Logger.error('Image compression failed: Source file does not exist');
        return null;
      }

      Logger.info('Compressing image: ${file.path} -> $targetPath');

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: _maxDimension,
        minHeight: _maxDimension,
        quality: _quality,
      );

      if (result == null) {
        Logger.error('Image compression failed: Result is null');
        return null;
      }

      final compressedFile = File(result.path);

      // Log savings
      final originalSize = await file.length();
      final compressedSize = await compressedFile.length();
      final savings = ((originalSize - compressedSize) / originalSize * 100)
          .toStringAsFixed(1);

      Logger.info(
          'Compression complete: $originalSize bytes -> $compressedSize bytes ($savings% saved)');

      return compressedFile;
    } catch (e) {
      Logger.error('Error compressing image', error: e);
      return null;
    }
  }
}
