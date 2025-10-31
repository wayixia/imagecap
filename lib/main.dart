import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

import 'mainframe.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get the current window controller
  //final windowController = await WindowController.fromCurrentEngine();
  
  // Parse window arguments to determine which window to show
  //final arguments = parseArguments(windowController.arguments);
  
  // Run different apps based on the window type
  // switch (arguments.type) {
  //   case YourArgumentDefinitions.main:
      runApp(const MyApp());
  //   case YourArgumentDefinitions.sample:
  //     runApp(const SampleWindow());
  //   // Add more window types as needed
  // }
}

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: MainFrame(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: 
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        HighlightListView(
          items: List.generate(8, (index) => 'Item $index'),
        ),
        // ListView( 
        //   children: List.generate(10, (index) {
        //     return ListTile(
        //       leading: Icon(Icons.label),
        //       title: Text('Item $index'),
        //       mouseCursor: SystemMouseCursors.move,
        //       selectedColor: Color.fromARGB(255, 137, 11, 11), 
        //       hoverColor: Color.fromARGB(255,255,0, 255),
        //       tileColor: Color.fromARGB(255, 0, 204, 204),
        //       selectedTileColor: Color.fromARGB(255, 255, 255, 0),
        //     );
        //   })
      
      
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class HighlightListView extends StatefulWidget {
  final List<String> items;

  HighlightListView({required this.items});

  @override
  _HighlightListViewState createState() => _HighlightListViewState();
}

class _HighlightListViewState extends State<HighlightListView> {
  int? _highlightedIndex;
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        bool isHighlighted = _highlightedIndex == index;
        bool isSelected = _selectedIndex == index;
        return MouseRegion(
          onEnter: (event) => _highlight(index),
          onExit: (event) => _highlight(null),
          child: ListTile(
            title: Text(widget.items[index]),
            selected: isSelected, // 使用selected属性来显示高亮效果
            selectedColor: Colors.white, // 高亮颜色
            selectedTileColor: Colors.green, // 选中颜色
            trailing: Icon(Icons.star, color: (isHighlighted||isSelected) ?Colors.white:Colors.grey),
            onTap: () {
              // 处理点击事件
              _selectedIndex = index;
              setState(() {});
            },
          ),
        );
      },
    );
  }

  void _highlight(int? index) {
    setState(() {
      _highlightedIndex = index;
    });
  }
}



