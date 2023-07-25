import 'package:flutter/material.dart';

class TextCheckbox extends StatefulWidget {
  final bool value;
  final String label;
  final Function(bool?)? onChanged;

  const TextCheckbox(
      {Key? key,
      required this.label,
      required this.value,
      required this.onChanged})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TextChecboxState createState() => _TextChecboxState();
}

class _TextChecboxState extends State<TextCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: widget.value, onChanged: widget.onChanged),
        Text(widget.label),
      ],
    );
  }
}
