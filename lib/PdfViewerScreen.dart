import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  const PdfViewerScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late File Pfile;
  bool isLoading = false;
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  late PDFViewController pdfViewController;
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  void initState() {
    setState(() {
      
    loadNetwork();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('PDF Viewer'),
         backgroundColor: Colors.grey,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              child: Center(
                child: PDFView(
                  filePath:Pfile.path,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: currentPage,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation:
                      false, // if set to true the link is handled in flutter
                  onRender: (_pages) {
                    setState(() {
                      pages = _pages!;
                      isReady = true;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                    print(error.toString());
                  },
                  onPageError: (page, error) {
                    setState(() {
                      errorMessage = '$page: ${error.toString()}';
                    });
                    print('$page: ${error.toString()}');
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                    _controller.complete(pdfViewController);
                  },
                  onLinkHandler: (String? uri) {
                    print('goto uri: $uri');
                  },
                  onPageChanged: (int? page, int? total) {
                    print('page change: $page/$total');
                    setState(() {
                      currentPage = page!;
                    });
                  },
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Page ${currentPage + 1} of $pages',
            style: const TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  Future<void> loadNetwork() async {

    try{
 setState(() {
      isLoading = true;
    });
    var url = widget.pdfUrl;
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();
    var file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: false);
    setState(() {
      Pfile = file;
    });

    print(Pfile);
    setState(() {
      isLoading = false;
    });
  }
    
     
       catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      print('Error initializing video player: $e');
    }

    }
   
}
