import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';

import 'file_context_menu.dart';

class FileHistoryCard extends StatefulWidget {
  List<FileSystemEntity> files;
  final Future<void> Function(FileSystemEntity)? onTapItem;
  final Future<void> Function()? onTapClear;

  FileHistoryCard(
      {super.key, required this.files, this.onTapItem, this.onTapClear});

  @override
  State<StatefulWidget> createState() => _FileHistoryCardState();
}

class _FileHistoryCardState extends State<FileHistoryCard> {
  late List<FileSystemEntity> _files;

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

  Future<void> _handleClear() async {
    if (widget.onTapClear != null) {
      await widget.onTapClear?.call();
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
      color: Theme.of(context).colorScheme.background,
      surfaceTintColor: Theme.of(context).colorScheme.tertiaryContainer,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 1,
                    shadowColor: Colors.transparent,
                    color: Theme.of(context).colorScheme.background,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search files',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _files = widget.files
                              .where((element) => element.path.contains(value))
                              .toList();
                        });
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _handleClear,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Expanded(
              child: Card(
                elevation: 2,
                color: Theme.of(context).colorScheme.surface,
                shadowColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _files.isNotEmpty
                      ? ListView(
                          children: [
                            for (final file in _files)
                              Center(
                                child: Tooltip(
                                  message: file.path
                                      .split(Platform.pathSeparator)
                                      .last,
                                  triggerMode: TooltipTriggerMode.tap,
                                  waitDuration:
                                      const Duration(milliseconds: 750),
                                  preferBelow: false,
                                  child: ContextMenuRegion(
                                    contextMenu:
                                        FileContextMenu(filePath: file.path),
                                    child: Card(
                                      elevation: 0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceVariant,
                                      child: ListTile(
                                        leading: _getIcon(file.path
                                            .split(Platform.pathSeparator)
                                            .last),
                                        title: Text(
                                          file.path
                                              .split(Platform.pathSeparator)
                                              .last,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // subtitle: Text(file.path),
                                        trailing: InkWell(
                                          splashColor: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          onTap: () => {_handleTap(file)},
                                          child: const Icon(
                                              Icons.chevron_right_rounded,
                                              size: 35),
                                        ),
                                      ),
                                    ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
