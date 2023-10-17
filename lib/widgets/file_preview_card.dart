import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:randomizer/widgets/file_context_menu.dart';

class FilePreviewCard extends StatefulWidget {
  final String filePath;
  final Future<void> Function()? onTap;
  final bool useHoverPreview;

  const FilePreviewCard(
      {super.key,
      required this.filePath,
      this.onTap,
      this.useHoverPreview = false});

  @override
  State<FilePreviewCard> createState() => _FilePreviewCardState();
}

class _FilePreviewCardState extends State<FilePreviewCard> {
  final Player player = Player();

  late String _fileName;
  late File _file;
  late String _type;
  late bool _isFolder;

  bool _isInPreview = false;

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void didUpdateWidget(covariant FilePreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      setup();
    }
  }

  void setup() {
    _file = File(widget.filePath);
    _fileName = widget.filePath.split(Platform.pathSeparator).last;
    _type = widget.filePath.split('.').last;
    _isFolder = _file.statSync().type == FileSystemEntityType.directory;

    if (_type == 'mp4' || _type == 'mov') {
      player.open(Media('file:///${_file.path}'));
      Future.delayed(const Duration(seconds: 1), () {
        player.pause();
      });
    }
  }

  Future<void> _handleTap() async {
    if (widget.onTap != null) {
      await widget.onTap!();
    }

    if (_type.toLowerCase() != 'mp4' && _type.toLowerCase() != 'mov') {
      OpenAppFile.open(widget.filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: double.infinity,
        height: 200,
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: ContextMenuRegion(
            contextMenu: FileContextMenu(filePath: _file.path),
            child: Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(fit: StackFit.expand, children: [
                RegExp('(jpe?g|png|gif|bmp)').hasMatch(_type)
                    ? Image.file(_file, fit: BoxFit.cover)
                    : _type == 'mp4' || _type == 'mov'
                        ? Video(
                            controller: VideoController(player),
                            fit: BoxFit.cover,
                          )
                        : _isFolder
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.folder))
                            : const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.insert_drive_file)),
                Positioned(
                  top: -.1,
                  left: -1,
                  right: -1,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(7.5, 0, 7.5, 3),
                    alignment: Alignment.topLeft,
                    height: 30,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Color.fromARGB(150, 0, 0, 0),
                          Colors.transparent,
                        ])),
                    child: Text(
                      _fileName,
                      style: const TextStyle(
                        height: 1.75,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
