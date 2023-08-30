import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_compress_plus/video_compress_plus.dart';

class FirebaseHelper {
  uploadVideo(File videoFile) async {
    try {
      //Compress Video File
      final compressedInfo = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      //Upload to Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('videos/${DateTime.now()}.mp4');
      UploadTask uploadTask = storageRef.putFile(File(compressedInfo!.path!));

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await storageRef.getDownloadURL();

        print('Video download URL: $downloadUrl');

        await saveVideoMetadata(downloadUrl);
      }
    } catch (e) {
      print('Upload Error: $e');
    }
  }

  //Upload Metadata to firebase Firestore
  Future<void> saveVideoMetadata(String downloadURL) async {
    try {
      final CollectionReference videosCollection =
          FirebaseFirestore.instance.collection('videos');

      await videosCollection.add({
        'title': downloadURL,
        'uploadDate': FieldValue
            .serverTimestamp(), // Automatically set the current server timestamp
      });
    } catch (e) {
      print('Error saving video metadata: $e');
    }
  }
}
