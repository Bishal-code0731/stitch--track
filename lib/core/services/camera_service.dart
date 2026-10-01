import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Wraps camera/gallery capture ([image_picker]) plus compression ([flutter_image_compress]).
class CameraService {
  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Target maximum size for a stored photo.
  static const int maxBytes = 500 * 1024;

  /// Capture from the camera and return the compressed file (null if the user cancels).
  Future<File?> captureFromCamera() => _pickAndCompress(ImageSource.camera);

  /// Pick from the gallery and return the compressed file (null if cancelled).
  Future<File?> pickFromGallery() => _pickAndCompress(ImageSource.gallery);

  Future<File?> _pickAndCompress(ImageSource source) async {
    final shot = await _picker.pickImage(
      source: source,
      maxWidth: 2000,
      imageQuality: 90,
    );
    if (shot == null) return null;
    return compressToLimit(File(shot.path));
  }

  Future<File> compressToLimit(File input) async {
    final dir = await getApplicationDocumentsDirectory();
    final targetPath = p.join(
      dir.path,
      'img_${input.uri.pathSegments.last}_c.jpg',
    );

    var quality = 88;
    var minWidth = 2000;
    File? result;
    for (var attempt = 0; attempt < 6; attempt++) {
      final xfile = await FlutterImageCompress.compressAndGetFile(
        input.absolute.path,
        targetPath.replaceFirst('.jpg', '_$attempt.jpg'),
        quality: quality,
        minWidth: minWidth,
        minHeight: minWidth,
        format: CompressFormat.jpeg,
      );
      if (xfile == null) break;
      result = File(xfile.path);
      if (await result.length() <= maxBytes) break;
      quality = (quality - 15).clamp(30, 100);
      minWidth = (minWidth * 0.8).round();
    }
    return result ?? input;
  }
}

final cameraServiceProvider = Provider<CameraService>((ref) => CameraService());
