import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class FileOpener {
  static Future<void> openFile(String url) async {
    print('Opening file: $url');

    if (url.endsWith('.jpg') || url.endsWith('.png') || url.endsWith('.jpeg')) {
      await launchUrl(Uri.parse(url)); // Opens images in browser
    } else if (url.endsWith('.pdf') || url.endsWith('.xls') || url.endsWith('.xlsx') || url.endsWith('.doc') || url.endsWith('.docx')) {
      await _downloadAndOpenFile(url);
    } else {
      await _downloadAndOpenFile(url); // Open any other file type after downloading
    }
  }

  static Future<void> _downloadAndOpenFile(String url) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = path.basename(url);
      final filePath = path.join(dir.path, fileName);

      // Download the file if it doesn't already exist
      if (!File(filePath).existsSync()) {
        print('Downloading file to: $filePath');
        final response = await Dio().download(url, filePath);
        if (response.statusCode == 200) {
          print('Download complete.');
        } else {
          print('Download failed with status: ${response.statusCode}');
          return;
        }
      } else {
        print('File already exists at: $filePath');
      }

      // Open the downloaded file
      await OpenFilex.open(filePath);

    } catch (e) {
      print('Error while downloading or opening file: $e');
    }
  }
}
