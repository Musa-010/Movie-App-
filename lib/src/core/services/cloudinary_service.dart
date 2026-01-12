import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // Replace with your actual Cloudinary credentials
  static const String _cloudName = 'dci1w0pja';
  static const String _uploadPreset = 'Movie_app';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<String?> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      // print('Cloudinary upload error: $e');
      return null;
    }
  }
}
