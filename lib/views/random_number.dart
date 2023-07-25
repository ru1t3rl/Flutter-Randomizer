import 'dart:math';

import 'package:flutter/material.dart';
import '../widgets/nummeric_updown.dart';

class RandomNumber extends StatefulWidget {
  const RandomNumber({super.key});

  @override
  _RandomNumberState createState() => _RandomNumberState();
}

class _RandomNumberState extends State<RandomNumber> {
  Random _rnd = Random();

  String _spinValue = '"Hit Spin"';
  String _seed = "Random Seed";

  int minValue = 0;
  int maxValue = 0;

  bool _busy = false;

  @override
  void initState() {
    super.initState();

    _rnd = Random(_seed.hashCode);
  }

  Future<void> spin({int? cycles}) async {
    setState(() => _busy = true);
    cycles ??= 50;

    if (minValue == 0 && maxValue == 0 ||
        minValue > maxValue ||
        minValue == maxValue) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        showCloseIcon: true,
        content: Text('Please set a valid min and max value!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.fromARGB(225, 20, 20, 20),
      ));
      setState(() => _busy = false);
      return;
    }

    for (int i = 0; i < cycles; i++) {
      setState(() => _spinValue =
          (minValue + (_rnd.nextInt(maxValue - minValue + 1))).toString());
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
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Card(
            child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NummericUpDown(
                    label: 'Min:',
                    maxValue: maxValue,
                    onChanged: (value) async {
                      setState(() => minValue = value);
                    }),
                NummericUpDown(
                    label: 'Max:',
                    minValue: minValue,
                    onChanged: (value) async {
                      setState(() => maxValue = value);
                    }),
              ]),
        )),
        Text(_spinValue),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: FilledButton.tonal(
              onPressed: !_busy ? spin : null,
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.casino_outlined),
                    SizedBox(width: 10),
                    Text('Spin')
                  ]),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: !_busy ? generateSeed : null,
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.text_fields),
                    SizedBox(width: 10),
                    Text('Generate Seed')
                  ]),
            ),
          ),
        ]),
      ],
    ));
  }
}
