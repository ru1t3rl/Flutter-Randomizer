import 'dart:io';

import 'package:flutter/material.dart';

class FileHistoryCard extends StatefulWidget {
  List<FileSystemEntity> files;
  final Future<void> Function(FileSystemEntity)? onTapItem;

  FileHistoryCard({super.key, required this.files, this.onTapItem});

  @override
  State<StatefulWidget> createState() => _FileHistoryCardState();
}

class _FileHistoryCardState extends State<FileHistoryCard> {
  late final List<FileSystemEntity> _files;

  @override
  void initState() {
    super.initState();
    _files = widget.files;
  }

  Future<void> _handleTap(FileSystemEntity file) async {
    if (widget.onTapItem != null) {
      await widget.onTapItem?.call(file);
    }
  }

  Icon _getIcon(String fileName) {
    switch (fileName.split('.').last) {
      case 'mp4':
        return const Icon(Icons.movie);
      case 'pdf':
        return const Icon(Icons.picture_as_pdf);
      case 'docx':
        return const Icon(Icons.document_scanner);
      case 'xlsx':
        return const Icon(Icons.table_chart);
      case 'pptx':
        return const Icon(Icons.slideshow);
      case 'txt':
        return const Icon(Icons.text_fields);
      case 'zip':
      case 'rar':
      case '7z':
      case 'tar':
      case 'gz':
      case 'tgz':
        return const Icon(Icons.archive);
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'webp':
      default:
        return const Icon(Icons.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: _files.isNotEmpty
          ? ListView(
              children: [
                for (final file in _files)
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: InkWell(
                      splashColor: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => {_handleTap(file)},
                      child: ListTile(
                        leading: _getIcon(
                            file.path.split(Platform.pathSeparator).last),
                        title:
                            Text(file.path.split(Platform.pathSeparator).last),
                        // subtitle: Text(file.path),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 50),
                  SizedBox(height: 5),
                  Text(
                      textAlign: TextAlign.center,
                      'No files found.\nSpin to build up an epic history!')
                ],
              ),
            ),
    );
  }
}
