// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, avoid_print

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_compress_plus/video_compress_plus.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Video Upload',
      home: VideoUploadScreen(),
    );
  }
}

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  File? _videoFile;
  bool _isloading = false;

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
      });
    } else {}
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) {
      print('No video file selected');
      return;
    }
    try {
      setState(() {
        _isloading = true;
      });
      final info = await VideoCompress.compressVideo(
        _videoFile!.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      Reference storageRef =
          FirebaseStorage.instance.ref().child('videos/${DateTime.now()}.mp4');
      UploadTask uploadTask = storageRef.putFile(File(info!.path!));

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await storageRef.getDownloadURL();

        print('Video download URL: $downloadUrl');
        setState(() {
          _isloading = false;
        });
      }
    } catch (error) {
      print('Error uploading video: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Video Upload'),
      ),
      body: _isloading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _videoFile != null
                      ? Text('Video Selected: ${_videoFile!.path}')
                      : Text('No Video Selected'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickVideo,
                    child: Text('Pick a Video'),
                  ),
                  ElevatedButton(
                    onPressed: _uploadVideo,
                    child: Text('Upload Video'),
                  ),
                ],
              ),
            ),
    );
  }
}

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final Reference storageRef = FirebaseStorage.instance.ref().child('videos');
//   VideoPlayerController? _videoController;
//   String? _videoUrl;
//   @override
//   void initState() {
//     // _videoController;
//     super.initState();
//   }

//   void uploadVideo() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
// if (result != null) {
//     Reference videoRef = storageRef
//         .child('video.mp4'); // Replace 'video.mp4' with your desired file name
//     File videoFile = pickVideo();

//     UploadTask task = videoRef.putFile(videoFile);

//     // Listen for state changes, errors, and completion of the upload.
//     task.snapshotEvents.listen((TaskSnapshot snapshot) {
//       print(
//           'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
//     }, onError: (dynamic error) {
//       print('Error: $error');
//     }, onDone: () {
//       print('Upload complete');
//     });
// } else {
//   // User canceled the file selection.
// }
//   }

//   void _pickVideo() async {
//     // uploadVideo();
//     _videoUrl = await pickVideo();
//     _iniTializeVideoController();
//   }

//   void _iniTializeVideoController() async {
//     try {
//       _videoController = VideoPlayerController.file(File(_videoUrl!))
//         ..initialize().then((_) {
//           setState(() {});
//           _videoController!.play();
//         });
//     } catch (e) {
//       print('Error in initializing: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//           appBar: AppBar(title: Text('Video Compressor')),
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   child: Text("VIdeo Compressor"),
//                   onPressed: () {
//                     _pickVideo();
//                   },
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 _videoUrl == null
//                     ? Text('No video selected')
//                     : _videoController != null
//                         ? Stack(
//                             children: [
//                               SizedBox(
//                                 height: 250,
//                                 child: VideoPlayer(
//                                   _videoController!,
//                                 ),
//                               ),
//                               Positioned(
//                                 child: SizedBox(
//                                   height: 250,
//                                   width: MediaQuery.of(context).size.width,
//                                   child: IconButton(
//                                     icon: Icon(
//                                       _videoController!.value.isPlaying
//                                           ? Icons.pause
//                                           : Icons.play_circle,
//                                       size: 80,
//                                       color: Colors.white,
//                                     ),
//                                     onPressed: () =>
//                                         _videoController!.value.isPlaying
//                                             ? _videoController!.pause()
//                                             : _videoController!.play(),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : CircularProgressIndicator(),
//               ],
//             ),
//           )),
//     );
//   }
// }
