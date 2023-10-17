import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_app_file/open_app_file.dart';

class FileContextMenu extends StatelessWidget {
  final String filePath;

  const FileContextMenu({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return GenericContextMenu(buttonConfigs: [
      ContextMenuButtonConfig(
        'Open',
        onPressed: () {
          OpenAppFile.open(filePath);
        },
      ),
      ContextMenuButtonConfig(
        'Copy path',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: filePath));
        },
      ),
      ContextMenuButtonConfig(
        'Show in explorer',
        onPressed: () {
          Process.run('explorer.exe', ['/select,', filePath]);
        },
      ),
    ]);
  }
}
