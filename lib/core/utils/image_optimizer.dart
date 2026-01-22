import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Image optimization utility for compressing and resizing images
class ImageOptimizer {
  /// Maximum image dimensions
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;
  static const int thumbnailSize = 300;

  /// JPEG quality (0-100)
  static const int defaultQuality = 85;
  static const int thumbnailQuality = 75;

  /// Optimize image file (compress and resize)
  static Future<File> optimizeImage(
    File imageFile, {
    int? maxWidth,
    int? maxHeight,
    int quality = defaultQuality,
  }) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();

      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed
      final targetWidth = maxWidth ?? ImageOptimizer.maxWidth;
      final targetHeight = maxHeight ?? ImageOptimizer.maxHeight;

      if (image.width > targetWidth || image.height > targetHeight) {
        image = img.copyResize(
          image,
          width: image.width > targetWidth ? targetWidth : null,
          height: image.height > targetHeight ? targetHeight : null,
        );
      }

      // Encode as JPEG with compression
      final optimizedBytes = img.encodeJpg(image, quality: quality);

      // Save optimized image
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final optimizedFile = File('${tempDir.path}/optimized_$timestamp.jpg');
      await optimizedFile.writeAsBytes(optimizedBytes);

      if (kDebugMode) {
        final originalSize = bytes.length / 1024;
        final optimizedSize = optimizedBytes.length / 1024;
        final reduction = ((originalSize - optimizedSize) / originalSize * 100)
            .toStringAsFixed(1);
        print(
            '[IMAGE_OPTIMIZER] Original: ${originalSize.toStringAsFixed(1)}KB, Optimized: ${optimizedSize.toStringAsFixed(1)}KB, Reduction: $reduction%');
      }

      return optimizedFile;
    } catch (e) {
      if (kDebugMode) {
        print('[IMAGE_OPTIMIZER] Error optimizing image: $e');
      }
      rethrow;
    }
  }

  /// Generate thumbnail from image
  static Future<File> generateThumbnail(
    File imageFile, {
    int size = thumbnailSize,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Create square thumbnail
      final thumbnail = img.copyResizeCropSquare(image, size: size);

      // Encode with lower quality for thumbnails
      final thumbnailBytes =
          img.encodeJpg(thumbnail, quality: thumbnailQuality);

      // Save thumbnail
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final thumbnailFile = File('${tempDir.path}/thumb_$timestamp.jpg');
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      if (kDebugMode) {
        print(
            '[IMAGE_OPTIMIZER] Generated thumbnail: ${thumbnailBytes.length / 1024}KB');
      }

      return thumbnailFile;
    } catch (e) {
      if (kDebugMode) {
        print('[IMAGE_OPTIMIZER] Error generating thumbnail: $e');
      }
      rethrow;
    }
  }

  /// Optimize image from bytes
  static Future<Uint8List> optimizeImageBytes(
    Uint8List bytes, {
    int? maxWidth,
    int? maxHeight,
    int quality = defaultQuality,
  }) async {
    try {
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final targetWidth = maxWidth ?? ImageOptimizer.maxWidth;
      final targetHeight = maxHeight ?? ImageOptimizer.maxHeight;

      if (image.width > targetWidth || image.height > targetHeight) {
        image = img.copyResize(
          image,
          width: image.width > targetWidth ? targetWidth : null,
          height: image.height > targetHeight ? targetHeight : null,
        );
      }

      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } catch (e) {
      if (kDebugMode) {
        print('[IMAGE_OPTIMIZER] Error optimizing image bytes: $e');
      }
      rethrow;
    }
  }

  /// Check if image needs optimization
  static Future<bool> needsOptimization(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final sizeInMB = bytes.length / (1024 * 1024);

      // Optimize if larger than 2MB
      if (sizeInMB > 2) return true;

      img.Image? image = img.decodeImage(bytes);
      if (image == null) return false;

      // Optimize if dimensions exceed max
      return image.width > maxWidth || image.height > maxHeight;
    } catch (e) {
      return false;
    }
  }

  /// Get image dimensions
  static Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return null;

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      return null;
    }
  }
}
