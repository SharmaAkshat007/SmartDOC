import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PickImage {
  Future<File> captureImage() async {
    ImagePicker _pick = ImagePicker();
    final pickedFile = await _pick.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }
}
