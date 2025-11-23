import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'contact_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
        return savedImage.path;
      }
    } catch (e) {
      print('Erreur lors de la sélection d\'image: $e');
    }
    return null;
  }

  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (photo != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'contact_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(photo.path).copy('${appDir.path}/$fileName');
        return savedImage.path;
      }
    } catch (e) {
      print('Erreur lors de la prise de photo: $e');
    }
    return null;
  }

  Widget buildContactImage(String? imagePath, {double size = 50}) {
    if (imagePath != null && File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color(AppConstants.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: size * 0.5,
        ),
      );
    }
  }

  Future<void> deleteImage(String? imagePath) async {
    if (imagePath != null) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Erreur lors de la suppression d\'image: $e');
      }
    }
  }
}