// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, deprecated_member_use

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<String> videoUrls = [];

  Future<List<String>> fetchVideoUrls() async {
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
    fetchVideoUrls().then((urls) {
      setState(() {
        videoUrls = urls;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return videoUrls.isNotEmpty
        ? ListView.builder(
            itemCount: videoUrls.length,
            itemBuilder: (context, index) {
              return VideoPlayerWidget(videoUrl: videoUrls[index]);
            },
          )
        : Center(child: CircularProgressIndicator());
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
  bool isPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });

    // if (isPlaying) {
    //   _controller.play();
    // } else {
    //   _controller.pause();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: _controller.value.isInitialized
            ? Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: VideoPlayer(_controller),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 40,
                    top: MediaQuery.of(context).size.width / 2 - 40,
                    child: GestureDetector(
                      onTap: () {
                        if (isPlaying) {
                          setState(() {
                            _controller.pause();
                            isPlaying = false;
                          });
                        } else {
                          setState(() {
                            _controller.play();
                            isPlaying = true;
                          });
                        }
                      },
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
