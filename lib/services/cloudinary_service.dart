import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

/// Upload-only service — no Firestore here, kept separate from
/// [CrudService] so each service does one job.
class CloudinaryService {
  // Replace with your actual cloud name and unsigned upload preset.
  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'xotxzz0h',
    'flutter_notes_presets',
    cache: false,
  );

  /// Uploads [file] and returns the hosted URL to save on the Firestore
  /// document. [folder] keeps the Cloudinary media library organized
  /// ("packages" or "receipts").
  static Future<String> uploadImage(File file, {String folder = 'packages'}) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        folder: folder,
        resourceType: CloudinaryResourceType.Image,
      ),
    );
    return response.secureUrl;
  }
}
