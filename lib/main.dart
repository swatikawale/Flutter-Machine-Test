import 'package:flutter/material.dart';
import 'package:testapp/PdfViewerScreen.dart'; 
import 'package:testapp/videoplayerscreen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: 
      
      DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final List<String> videos = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',

    // Add more video URLs here
  ];

  final List<String> pdfs = [
    'https://www.tutorialspoint.com/flutter/flutter_tutorial.pdf',
    'https://riptutorial.com/Download/dart.pdf',
    'https://www.tutorialspoint.com/java/java_tutorial.pdf',
    'https://www.tutorialspoint.com/javascript/javascript_tutorial.pdf',
    'https://www.tutorialspoint.com/cprogramming/cprogramming_tutorial.pdf',
    // Add more PDF URLs here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Dashboard')),
        backgroundColor: Colors.grey,
      ),
      body: ListView.builder(
        itemCount: videos.length + pdfs.length,
        itemBuilder: (context, index) {
          if (index < videos.length) {
            return ListTile(
              selectedTileColor: Colors.grey,
              title: Row(
                children: [
                  const Icon(
                    Icons.video_library,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                  Text(
                      '${videos[index].split('/').last.replaceAll(r'\((/.*)\)', '')}' 
                      ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                         VideoPlayerScreen(videoUrl: videos[index],)            
                  ),
                );
              },
            );
          } else {
            final pdfIndex = index - videos.length;
            return ListTile(
              title: Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 40,
                  ),
                  Text(
                      ' ${pdfs[pdfIndex].split('/').last.replaceAll(r'\((/.*)\)', '')}', 
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    PdfViewerScreen(pdfUrl: pdfs[pdfIndex]), 
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

