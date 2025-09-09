import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'routes.dart'; // Contains appRoutes and generateRoute

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kikay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Urbanist',
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: appRoutes, // 👈 static routes
      onGenerateRoute: generateRoute, // 👈 dynamic route handler
    );
  }
}
