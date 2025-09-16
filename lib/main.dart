import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:kikay/firebase_options.dart';
import 'routes.dart'; // Contains appRoutes and generateRoute
import 'services/model_service.dart';

late List<CameraDescription> cameras;
late ModelService modelService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Firebase.initializeApp(
    name: 'kikay-c23f6',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize model service
  print('Initializing model service...');
  modelService = ModelService();

  try {
    await modelService.loadModels();
    print('Model service initialized successfully');
  } catch (e) {
    print('Failed to initialize model service: $e');
    // We'll continue anyway so the app can still function
  }

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
