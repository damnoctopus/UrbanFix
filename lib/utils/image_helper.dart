import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageHelper {
  // Compress image to target size (best-effort). Returns compressed File path.
  static Future<File?> compressFile(File file, {int quality = 80}) async {
    final targetPath = '${file.parent.path}/uf_tmp_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final result = await FlutterImageCompress.compressAndGetFile(file.path, targetPath, quality: quality);
      if (result == null) return file;
      // Try to construct a File from the result's path (works for File or XFile)
      try {
        final path = (result as dynamic).path as String?;
        if (path != null) return File(path);
      } catch (_) {}
      return file;
    } catch (e) {
      return file;
    }
  }
}
