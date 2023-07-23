import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class RandomFilePicker extends StatefulWidget {
  const RandomFilePicker({super.key});

  @override
  _RandomFilePickerState createState() => _RandomFilePickerState();
}

class _RandomFilePickerState extends State<RandomFilePicker> {
  var directoryTF = TextEditingController();
  List<FileSystemEntity> files = [];
  Random _rnd = Random();

  bool _busy = false;
  bool _change = true;

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
    directoryTF.text = directoryPath;
  }

  Future<void> setDirectoryPath() async {
    String? result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select a directory', lockParentWindow: true);

    if (result != null) {
      setState(() => directoryPath = result);
    }

    directoryTF.text = directoryPath;
  }

  Future<void> getAllFiles() async {
    RegExp regex = RegExp(this.regex);

    List<FileSystemEntity> files = [];
    List<FileSystemEntity> directories = [];

    if (getFiles) {
      files = Directory(directoryPath)
          .listSync(recursive: recursive)
          .whereType<File>()
          .toList();
    }

    if (getDirectories) {
      directories = Directory(directoryPath)
          .listSync(recursive: recursive)
          .whereType<Directory>()
          .toList();
    }

    List<FileSystemEntity> allFiles = [...files, ...directories];
    if (useRegex) {
      allFiles =
          allFiles.where((element) => regex.hasMatch(element.path)).toList();
    }

    setState(() => this.files = allFiles);
    _spinValue = 'Got ${this.files.length} files!';
  }

  Future<void> spin({int? cycles}) async {
    setState(() => _busy = true);

    cycles ??= 50;

    if (files.isEmpty || _change) {
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

    setState(() => _busy = false);
  }

  Future<void> generateSeed(
      {int? length, int? smallestCharCode, int? biggestCharCode}) async {
    setState(() => _busy = true);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Card(
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Directory Path:',
                              textScaleFactor: 1.25,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller: directoryTF,
                              onChanged: (value) => setState(() {
                                directoryPath = value;
                                _change = true;
                              }),
                              decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  hintText: 'Select a directory'),
                            ),
                          ),
                          const SizedBox(width: 50),
                          FilledButton.tonal(
                              onPressed: setDirectoryPath,
                              child: const Text('Browse'))
                        ]),
                    Row(
                      children: [
                        Checkbox(
                            value: getFiles,
                            onChanged: (value) {
                              setState(() {
                                getFiles = value!;
                              });
                            }),
                        const Text('Get Files'),
                        const SizedBox(width: 20),
                        Checkbox(
                            value: getDirectories,
                            onChanged: (value) {
                              setState(() {
                                getDirectories = value!;
                                _change = true;
                              });
                            }),
                        const Text('Get Directories'),
                        const SizedBox(width: 20),
                        Checkbox(
                            value: recursive,
                            onChanged: (value) {
                              setState(() {
                                recursive = value!;
                                _change = true;
                              });
                            }),
                        const Text('Recursive'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: useRegex,
                            onChanged: (value) {
                              setState(() {
                                useRegex = value!;
                                _change = true;
                              });
                            }),
                        const Text('Regex'),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            enabled: useRegex,
                            decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                hintText: 'Regex'),
                            onChanged: (value) {
                              setState(() {
                                regex = value;
                                _change = true;
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  ])),
            ),
            Text(
              _spinValue,
              textAlign: TextAlign.center,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(children: [
                  FilledButton.tonal(
                      onPressed: getAllFiles,
                      child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_copy_outlined),
                            Text('Get Files')
                          ])),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                            onPressed: spin,
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
                            onPressed: generateSeed,
                            child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.casino_outlined),
                                  Text('New Seed')
                                ])),
                      ),
                    ],
                  )
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
