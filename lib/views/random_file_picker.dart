import 'package:flutter/material.dart';

class RandomFilePicker extends StatefulWidget {
  const RandomFilePicker({super.key});

  @override
  _RandomFilePickerState createState() => _RandomFilePickerState();
}

class _RandomFilePickerState extends State<RandomFilePicker> {
  var directoryTF = TextEditingController();

  void setDirectoryPath() {
    directoryTF.text += "dj";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: Column(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
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
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    hintText: 'Select a directory'))),
                        const SizedBox(width: 50),
                        FilledButton.tonal(
                            onPressed: setDirectoryPath,
                            child: const Text('Browse'))
                      ]),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
