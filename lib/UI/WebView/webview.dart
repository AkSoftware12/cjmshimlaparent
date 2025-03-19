import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class WebViewExample extends StatefulWidget {
  final String title;
  final String url;

  const WebViewExample({super.key, required this.title, required this.url});

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;
  String? _currentUrl;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onPageFinished: (String url) {
              _currentUrl = url;
              _setZoomLevel(0.5); // Adjust zoom
            },
            navigationDelegate: (NavigationRequest request) {
              if (_isDownloadableFile(request.url)) {
                _downloadFile(request.url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
          if (_isDownloading)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Downloading...",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _downloadFile(widget.url);
        },
        child: const Icon(Icons.download),
      ),
    );
  }

  void _setZoomLevel(double scale) {
    _controller.runJavascript(
        "document.querySelector('meta[name=\"viewport\"]')?.setAttribute('content', 'width=device-width, initial-scale=$scale, maximum-scale=$scale, user-scalable=no');"
    );
  }

  bool _isDownloadableFile(String url) {
    return url.endsWith('.pdf') ||
        url.endsWith('.zip') ||
        url.endsWith('.doc') ||
        url.endsWith('.xlsx');
  }

  Future<void> _downloadFile(String url) async {
    if (!await _requestPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied.")),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      Dio dio = Dio();
      String fileName = url.split('/').last;
      Directory? directory = await getExternalStorageDirectory();
      String filePath = "${directory?.path}/$fileName";

      await dio.download(url, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloaded: $fileName")),
      );

      // If the file is a PDF, generate a new PDF
      if (fileName.endsWith('.pdf')) {
        await _generatePdf(directory?.path ?? "", "Confirmation_$fileName");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download failed.")),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _generatePdf(String directoryPath, String newFileName) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text("Your PDF has been downloaded successfully!"),
        ),
      ),
    );

    final file = File("$directoryPath/$newFileName");
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Generated: $newFileName")),
    );

    // Open the generated PDF
    OpenFile.open(file.path);
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return true;
  }
}
