import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';

class FilePreviewCard extends StatefulWidget {
  final String filePath;
  final Future<void> Function()? onTap;

  const FilePreviewCard({super.key, required this.filePath, this.onTap});

  @override
  State<FilePreviewCard> createState() => _FilePreviewCardState();
}

class _FilePreviewCardState extends State<FilePreviewCard> {
  final _controller = MeeduPlayerController(
    controlsEnabled: false,
    initialFit: BoxFit.contain,
  );

  final _fullscreenController = MeeduPlayerController(
    controlsStyle: ControlsStyle.secondary,
    controlsEnabled: true,
    initialFit: BoxFit.contain,
  );

  late final String _fileName;
  late final File _file;
  late final String _type;
  late final bool _isFolder;

  @override
  void initState() {
    super.initState();
    _file = File(widget.filePath);
    _fileName = widget.filePath.split(Platform.pathSeparator).last;

    _type = widget.filePath.split('.').last;
    _isFolder = _file.statSync().type == FileSystemEntityType.directory;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  _init() {
    if (_type == 'mp4') {
      _controller.setVolume(0);
      _controller.setPlaybackSpeed(0.01);
      _controller.setDataSource(
        DataSource(
          type: DataSourceType.file,
          file: _file,
        ),
        autoplay: false,
      );

      _fullscreenController.setDataSource(
        DataSource(
          type: DataSourceType.file,
          file: _file,
        ),
        autoplay: false,
      );

      _fullscreenController.onFullscreenChanged.listen((isFullscreen) {
        if (!isFullscreen) {
          _onCloseFullscreen();
        }
      });
    }
  }

  Future<void> _handleTap() async {
    if (widget.onTap != null) {
      await widget.onTap!();
    }

    if (_type == 'mp4') {
      _fullscreenController.setVolume(1);
      _fullscreenController.setPlaybackSpeed(1);
      _fullscreenController.play();
      _fullscreenController.setFullScreen(true, context);
    }
  }

  void _onCloseFullscreen() {
    _fullscreenController.setVolume(0);
    _fullscreenController.setPlaybackSpeed(0.01);
    _fullscreenController.pause();
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
          child: Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(fit: StackFit.expand, children: [
                RegExp('(jpe?g|png|gif|bmp)').hasMatch(_type)
                    ? Image.file(_file, fit: BoxFit.cover)
                    : _type == 'mp4'
                        ? MeeduVideoPlayer(
                            controller: _controller,
                          )
                        : _isFolder
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.folder))
                            : const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.insert_drive_file)),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(7.5, 0, 7.5, 3),
                    alignment: Alignment.topLeft,
                    color:
                        Theme.of(context).colorScheme.surface.withOpacity(.9),
                    child: Text(
                      _fileName,
                      style: const TextStyle(
                        height: 1.5,
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
