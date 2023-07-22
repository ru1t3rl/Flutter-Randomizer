import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var directoryTF = TextEditingController();
  int _counter = 0;
  String path = '';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void setDirectoryPath() {
    directoryTF.text += "dj";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                      onPressed: setDirectoryPath, child: const Text('Browse'))
                ]),
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
            ),
            label: "Home",
            tooltip: "The homepage"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.numbers_rounded,
            ),
            label: "Random Number",
            tooltip: "Generate random numbers")
      ]),
    );
  }
}
