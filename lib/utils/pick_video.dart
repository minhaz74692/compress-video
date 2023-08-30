// ignore_for_file: avoid_print

// import 'package:image_picker/image_picker.dart';

// pickVideo() async {
//   final picker = ImagePicker();
//   XFile? videoFile;
//   try {
//     videoFile = await picker.pickVideo(source: ImageSource.gallery);
//     print(videoFile!.path);
//     return videoFile.path.toString();
//   } catch (e) {
//     print('Error picking video');
//   }
// }

import 'dart:io';

import 'package:file_picker/file_picker.dart';

pickVideo() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.video);

  if (result != null) {
    return File(result.files.single.path!);
    
  } else {}
}
