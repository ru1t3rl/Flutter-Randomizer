import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/widgets/file_history_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/text_checkbox.dart';

import '../widgets/file_preview_card.dart';

class RandomFilePicker extends StatefulWidget {
  const RandomFilePicker({super.key});

  @override
  _RandomFilePickerState createState() => _RandomFilePickerState();
}

class _RandomFilePickerState extends State<RandomFilePicker> {
  late final SharedPreferences prefs;

  var directoryTF = TextEditingController();
  List<FileSystemEntity> files = [];
  final List<FileSystemEntity> _filesHistory = [];
  Random _rnd = Random();

  bool _busy = false;
  bool _dirty = true;
  bool _isSpinResult = false;
  bool _useHistory = false;

  int randomIndex = 0;

  String directoryPath = '';
  String regex = '';
  String _seed = 'Random Seed';
  String _spinValue = '"Hit Spin"';

  bool getFiles = true;
  bool getDirectories = false;
  bool recursive = false;
  bool useRegex = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });

    directoryTF.text = directoryPath;
  }

  void _init() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      directoryPath = prefs.getString('directoryPath') ?? directoryPath;
      getFiles = prefs.getBool('getFiles') ?? getFiles;
      getDirectories = prefs.getBool('getDirectories') ?? getDirectories;
      recursive = prefs.getBool('recursive') ?? recursive;
      useRegex = prefs.getBool('useRegex') ?? useRegex;
      regex = prefs.getString('regex') ?? regex;
    });
  }

  Future<void> setDirectoryPath() async {
    String? result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select a directory', lockParentWindow: true);

    if (result != null) {
      setState(() => directoryPath = result);
    }

    directoryTF.text = directoryPath;
    prefs.setString('directoryPath', directoryPath);
    setState(() => _dirty = true);
  }

  Future<void> getAllFiles() async {
    RegExp regex = RegExp(this.regex);

    List<FileSystemEntity> files = [];
    List<FileSystemEntity> directories = [];

    if (getFiles) {
      try {
        files = Directory(directoryPath)
            .listSync(recursive: recursive)
            .whereType<File>()
            .toList();
      } on PathNotFoundException {
        setState(() {
          _spinValue = 'Invalid directory!';
        });
        return;
      }
    }

    if (getDirectories) {
      try {
        directories = Directory(directoryPath)
            .listSync(recursive: recursive)
            .whereType<Directory>()
            .toList();
      } on PathNotFoundException {
        setState(() {
          _spinValue = 'Invalid directory!';
        });
        return;
      }
    }

    List<FileSystemEntity> allFiles = [...files, ...directories];
    if (useRegex) {
      allFiles =
          allFiles.where((element) => regex.hasMatch(element.path)).toList();
    }

    setState(() {
      this.files = allFiles;
      _dirty = false;
      _isSpinResult = false;
    });
    _spinValue = 'Got ${this.files.length} files!';
  }

  Future<void> onHistoryItemClicked(FileSystemEntity file) async {
    setState(() {
      randomIndex = _filesHistory.indexOf(file);
      _useHistory = true;
    });
  }

  Future<void> spin({int? cycles}) async {
    setState(() {
      _busy = true;
      _isSpinResult = false;
      _useHistory = false;
    });

    cycles ??= 50;

    if (files.isEmpty || _dirty) {
      await getAllFiles();

      if (files.isEmpty) {
        setState(() => _busy = false);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 1000));
    }

    for (int i = 0; i < cycles; i++) {
      setState(() {
        randomIndex = _rnd.nextInt(files.length);
        _spinValue = files[randomIndex].path.split('\\').last;
      });
      await Future.delayed(const Duration(milliseconds: 30));
    }

    _filesHistory.add(files[randomIndex]);

    setState(() {
      _busy = false;
      _isSpinResult = true;
    });
  }

  Future<void> generateSeed(
      {int? length, int? smallestCharCode, int? biggestCharCode}) async {
    setState(() {
      _busy = true;
      _isSpinResult = false;
      _useHistory = false;
    });
    length ??= 20;
    smallestCharCode ??= 33;
    biggestCharCode ??= 253;
    biggestCharCode =
        biggestCharCode < smallestCharCode ? smallestCharCode : biggestCharCode;

    _seed = "";

    for (int i = 0; i < length; i++) {
      _rnd = Random(_seed.isNotEmpty ? _seed.hashCode : null);
      _seed += String.fromCharCode(
          _rnd.nextInt(biggestCharCode - smallestCharCode + 1) +
              smallestCharCode);
      setState(() {
        _spinValue = _seed.toString();
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }

    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Card(
                  color: Theme.of(context).colorScheme.background,
                  surfaceTintColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  elevation: 4,
                  child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Path:',
                                  textScaleFactor: 1.25,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  controller: directoryTF,
                                  onChanged: !_busy
                                      ? (value) => setState(() {
                                            directoryPath = value;
                                            _dirty = true;
                                          })
                                      : null,
                                  decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      hintText: 'Select a directory'),
                                ),
                              ),
                              const SizedBox(width: 50),
                              FilledButton.tonal(
                                  onPressed: !_busy ? setDirectoryPath : null,
                                  child: const Text('Browse'))
                            ]),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: [
                              TextCheckbox(
                                  label: 'Get Files',
                                  value: getFiles,
                                  onChanged: !_busy
                                      ? (value) {
                                          setState(() {
                                            getFiles = value!;
                                          });

                                          prefs.setBool('getFiles', value!);
                                          _dirty = true;
                                        }
                                      : null),
                              TextCheckbox(
                                  label: 'Get Directories',
                                  value: getDirectories,
                                  onChanged: !_busy
                                      ? (value) {
                                          setState(() {
                                            getDirectories = value!;
                                          });

                                          prefs.setBool(
                                              'getDirectories', value!);
                                          _dirty = true;
                                        }
                                      : null),
                              TextCheckbox(
                                  label: 'Recursive',
                                  value: recursive,
                                  onChanged: !_busy
                                      ? (value) {
                                          setState(() {
                                            recursive = value!;
                                          });

                                          prefs.setBool('recursive', value!);
                                          _dirty = true;
                                        }
                                      : null),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            TextCheckbox(
                                label: 'Use Regex',
                                value: useRegex,
                                onChanged: !_busy
                                    ? (value) {
                                        setState(() {
                                          useRegex = value!;
                                          _dirty = true;
                                        });
                                        prefs.setBool('useRegex', value!);
                                      }
                                    : null),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                enabled: useRegex && !_busy,
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    hintText: 'Regex'),
                                onChanged: (value) {
                                  setState(() {
                                    regex = value;
                                    _dirty = true;
                                  });

                                  prefs.setString('regex', value);
                                },
                              ),
                            ),
                          ],
                        )
                      ])),
                ),
                _isSpinResult
                    ? FilePreviewCard(
                        filePath:
                            (_useHistory ? _filesHistory : files)[randomIndex]
                                .path)
                    : Text(
                        _spinValue,
                        key: Key(_spinValue),
                        textAlign: TextAlign.center,
                      ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                              onPressed: !_busy ? spin : null,
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.casino_outlined),
                                    Text('Spin')
                                  ])),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: FilledButton.tonal(
                              onPressed: !_busy ? generateSeed : null,
                              child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.casino_outlined),
                                    Text('New Seed')
                                  ])),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 195,
              bottom: 100,
              left: 0,
              child: SizedBox(
                width: 400 * MediaQuery.of(context).size.width / 1600,
                height: 200 * MediaQuery.of(context).size.width / 900,
                child: FileHistoryCard(
                  files: _filesHistory,
                  onTapItem: onHistoryItemClicked,
                  onTapClear: () async => setState(() {
                    _useHistory = false;
                    _isSpinResult = false;
                    _spinValue =
                        'There are ${files.length} files!\nHit spin again to get a new file!';
                    _filesHistory.clear();
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
