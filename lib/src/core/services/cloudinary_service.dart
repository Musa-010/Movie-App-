import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // Replace with your actual Cloudinary credentials
  static const String _cloudName = 'dci1w0pja';
  static const String _uploadPreset = 'Movie_app';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<String?> uploadImage(File imageFile) async {
    try {
      debugPrint('Cloudinary: Uploading image from ${imageFile.path}');
      debugPrint('Cloudinary: File exists: ${imageFile.existsSync()}, size: ${imageFile.lengthSync()} bytes');
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );
      debugPrint('Cloudinary: Upload success - ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }
}
