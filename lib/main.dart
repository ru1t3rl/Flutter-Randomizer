import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import '../views/home.dart';
import '../views/random_file_picker.dart';
import '../views/random_number.dart';

void main() {
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedPageIndex = 0;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Randomizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Padding(
            padding: const EdgeInsets.fromLTRB(12, 50, 12, 12),
            child: [
              const Home(),
              const RandomFilePicker(),
              const RandomNumber()
            ][selectedPageIndex]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedPageIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
                selectedIcon: Icon(Icons.home_rounded),
                icon: Icon(Icons.home_outlined),
                label: 'Home',
                tooltip: 'Overview of everything'),
            NavigationDestination(
                selectedIcon: Icon(Icons.video_camera_back_rounded),
                icon: Icon(Icons.video_camera_back_outlined),
                label: 'Random File',
                tooltip: 'Get a random file from the selected directory'),
            NavigationDestination(
                selectedIcon: Icon(Icons.pin_rounded),
                icon: Icon(Icons.pin_outlined),
                label: 'Random Number',
                tooltip: 'Get a random number from a set range')
          ],
        ),
      ),
    );
  }
}
