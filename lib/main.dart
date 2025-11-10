import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'main_frame.dart';
import 'wnds/capture/wnd.dart';
import 'package:args/args.dart';


Future<void> main(List<String> arguments) async 
{
  WidgetsFlutterBinding.ensureInitialized();

  // Must add this line.
  await windowManager.ensureInitialized();
  
  // Get the current window controller
  final windowController = await WindowController.fromCurrentEngine();
  
  // Create a parser
  final parser = ArgParser()
    ..addOption('name', abbr: 'n', defaultsTo: 'World', help: 'The name to greet.') // Option with a value
    ..addFlag('verbose', abbr: 'v', negatable: false, help: 'Enable verbose output.'); // Flag (true/false)

  // Parse window arguments to determine which window to show
  // Parse the arguments provided to main()
  ArgResults args = parser.parse(windowController.arguments.split(' '));
  
  // Run different apps based on the window type
  //switch (arguments.type) {
  //   case YourArgumentDefinitions.main:
  if( args['name'] == 'capturewnd') {
    // WindowOptions windowOptions = WindowOptions(
    //   size: Size(800, 600),
    //   center: true,
    //   backgroundColor: Colors.transparent,
    //   skipTaskbar: false,
    //   titleBarStyle: TitleBarStyle.hidden,
    //   windowButtonVisibility: false,
    // );
    // windowManager.waitUntilReadyToShow(windowOptions, () async {
    //   await windowManager.show();
    //   await windowManager.focus();
    // });
    runApp(const CaptureWndApp());
  } else {
    runApp(const ImagecapApp());
  }
}

// void main() {
//   runApp(const MyApp());
// }

class ImagecapApp extends StatelessWidget {
  const ImagecapApp({super.key});

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




