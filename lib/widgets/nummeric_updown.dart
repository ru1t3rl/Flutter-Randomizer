import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class NummericUpDown extends StatefulWidget {
  int? value;
  late int? minValue;
  late int? maxValue;
  final int step;
  final String label;
  final Future<void> Function(int) onChanged;

  NummericUpDown({
    Key? key,
    this.minValue,
    this.maxValue,
    this.value,
    this.step = 1,
    required this.label,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<NummericUpDown> createState() => _NummericUpDownState();
}

class _NummericUpDownState extends State<NummericUpDown> {
  final TextEditingController _inputTEC = TextEditingController();
  int _statefullValue = 0;

  @override
  void initState() {
    super.initState();
    _inputTEC.text = _statefullValue.toString();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _statefullValue = widget.value ?? 0;
        _inputTEC.text = _statefullValue.toString();
      });
    });
  }

  Future<void> _updateFromTextFieldValue() async {
    setState(() {
      _statefullValue = int.parse(_inputTEC.text);
      _statefullValue = _statefullValue.clamp(
          widget.minValue ?? -9999, widget.maxValue ?? 9999);
      widget.value = _statefullValue;
    });
  }

  Future<void> _updateValue(NummericUpDownUpdateType updateType) async {
    switch (updateType) {
      case NummericUpDownUpdateType.up:
        setState(() {
          _statefullValue += widget.step;
          _statefullValue = _statefullValue.clamp(
              widget.minValue ?? -9999, widget.maxValue ?? 9999);
          widget.value = _statefullValue;
        });
        break;
      case NummericUpDownUpdateType.down:
        setState(() {
          _statefullValue -= widget.step;
          _statefullValue = _statefullValue.clamp(
              widget.minValue ?? -9999, widget.maxValue ?? 9999);
          widget.value = _statefullValue;
        });
        break;
    }

    _inputTEC.text = _statefullValue.toString();
    await widget.onChanged.call(widget.value!);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(width: 20),
          Row(children: [
            IconButton.filledTonal(
                onPressed: () {
                  _updateValue(NummericUpDownUpdateType.down);
                },
                icon: const Icon(Icons.remove_rounded)),
            SizedBox.square(
              dimension: 50,
              child: TextField(
                maxLength: 4,
                controller: _inputTEC,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  int.parse(value) == _statefullValue
                      ? _updateFromTextFieldValue()
                      : "";
                },
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    hintText: 'Enter a number'),
              ),
            ),
            IconButton.filledTonal(
                onPressed: () {
                  _updateValue(NummericUpDownUpdateType.up);
                },
                icon: const Icon(Icons.add_rounded))
          ])
        ]);
  }
}

enum NummericUpDownUpdateType { up, down }
