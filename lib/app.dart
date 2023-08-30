// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, avoid_print

import 'dart:io';
import 'package:compress_video/firebase_helper/firebase_helper.dart';
import 'package:compress_video/utils/show_massege.dart';
import 'package:compress_video/widgets/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
    setState(() {
      _isloading = true;
    });
    try {
      await FirebaseHelper().uploadVideo(_videoFile!);
    } catch (e) {
      print('Upload and compression error: $e');
      showMessage('Video compress and upload failed!');
      setState(() {
        _isloading = false;
      });
    }
    showMessage('Video compress and upload successfully!');
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.video_call),
        onPressed: () async {
          await _pickVideo();
          _uploadVideo();
          print('Upload complete');
        },
      ),
      appBar: AppBar(
        title: Text('Video Compressor'),
      ),
      body: _isloading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(bottom: 90),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: VideoListScreen(),
                ),
              ),
            ),
    );
  }
}
