import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<FileSystemEntity> downloadedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final downloadDir =
        Directory('/storage/emulated/0/Download/YouTubeDownloads');
    if (await downloadDir.exists()) {
      final files = downloadDir.listSync().where((f) => f is File).toList();
      setState(() {
        downloadedFiles = files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloaded Videos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDownloads,
          ),
        ],
      ),
      body: downloadedFiles.isEmpty
          ? const Center(child: Text("No downloads yet"))
          : ListView.builder(
              itemCount: downloadedFiles.length,
              itemBuilder: (context, index) {
                final file = downloadedFiles[index];
                final fileName = file.path.split('/').last;

                return ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: Text(fileName),
                  onTap: () => OpenFile.open(file.path),
                );
              },
            ),
    );
  }
}
