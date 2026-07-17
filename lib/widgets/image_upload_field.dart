import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

/// Pick-and-upload widget used by the Post Package form (cover photo) and
/// the Payment Submission screen (receipt photo).
class ImageUploadField extends StatefulWidget {
  final String folder; // "packages" or "receipts"
  final void Function(String url) onUploaded;
  final String label;

  const ImageUploadField({
    super.key,
    required this.folder,
    required this.onUploaded,
    this.label = 'Tap to upload photo',
  });

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  File? _pickedImage;
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() {
      _pickedImage = File(picked.path);
      _isUploading = true;
    });

    try {
      final url = await CloudinaryService.uploadImage(_pickedImage!, folder: widget.folder);
      widget.onUploaded(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_pickedImage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_pickedImage!, height: 140, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
        InkWell(
          onTap: _isUploading ? null : _pickAndUpload,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                _isUploading
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
                const SizedBox(height: 6),
                Text(_isUploading ? 'Uploading...' : widget.label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
