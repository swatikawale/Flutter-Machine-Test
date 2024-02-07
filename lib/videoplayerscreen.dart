import 'package:flutter/material.dart';
import 'package:testapp/NotesPage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _vidcontroller;
    ChewieController? _chewieController;
   

  @override
  void initState() {
   super.initState();
    _vidcontroller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _vidcontroller!.initialize();
     
    _chewieController = ChewieController(
      videoPlayerController: _vidcontroller!,
      autoInitialize: true,
      autoPlay: true,
      looping: false,
      showControls: true,
      allowMuting: true, 
      allowFullScreen: true,
      draggableProgressBar: true,
      allowPlaybackSpeedChanging: true,
      useRootNavigator: true, 
      aspectRatio:_vidcontroller!.value.aspectRatio,  
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
              appBar: AppBar(
        title:const Text('Video Player'),
         backgroundColor: Colors.grey,
      ),
      body: _chewieController!.autoInitialize
          ? Column(children: [
              AspectRatio(
                aspectRatio: _vidcontroller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Chewie(
                      controller: _chewieController!,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10.0),
              const Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Align(
                    child: Text("Notes:",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    alignment: Alignment.topLeft,
                  )),
              const SizedBox(height: 10.0),
              //  var a=
              Expanded(
                child: NotesPage(timestamp: _vidcontroller!),
              ),
            ])
          : const Center(child: CircularProgressIndicator()),
    );
 
  }

  @override
  void dispose() {
    _vidcontroller!.dispose();
    _chewieController!.dispose();
    super.dispose();
  }
}
