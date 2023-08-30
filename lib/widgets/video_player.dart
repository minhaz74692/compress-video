// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  late List<String> videoUrls;

  Future<List<String>> fetchVideoUrls() async {
    final List<String> videoUrls = [];

    try {
      final ListResult result =
          await FirebaseStorage.instance.ref('videos').list();
      for (final Reference reference in result.items) {
        final url = await reference.getDownloadURL();
        videoUrls.add(url);
      }
    } catch (e) {
      print('Error fetching video URLs: $e');
    }

    return videoUrls;
  }

  @override
  void initState() {
    super.initState();
    fetchVideoUrls().then((urls) {
      setState(() {
        videoUrls = urls;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video List'),
      ),
      body: ListView.builder(
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return VideoPlayerWidget(videoUrl: videoUrls[index]);
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
