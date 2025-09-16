import 'package:flutter/material.dart';
import 'package:kikay/screens/splash.dart';
import 'package:kikay/screens/welcome.dart';
import 'package:kikay/screens/terms.dart';
import 'package:kikay/screens/home.dart';
import 'package:kikay/screens/camera.dart';
import 'package:kikay/screens/result.dart';
import 'package:kikay/screens/preferences.dart';
import 'package:kikay/screens/output.dart';
import 'package:kikay/screens/productinfo.dart'; // ✅ Import this
import 'package:kikay/services/model_service.dart';
import 'main.dart';

/// Static routes without arguments
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) =>
      SplashPage(onComplete: () => Navigator.pushNamed(context, '/welcome')),
  '/welcome': (context) =>
      WelcomePage(onNext: () => Navigator.pushNamed(context, '/terms')),
  '/terms': (context) =>
      TermsPage(onNext: () => Navigator.pushNamed(context, '/home')),
  '/home': (context) => const HomePage(),
  '/camera': (context) => CameraScreen(cameras: cameras),
  // Note: /preferences is handled dynamically since it needs arguments
};

/// Dynamic route generator for routes with arguments
Route<dynamic>? generateRoute(RouteSettings settings) {
  print('Generating route for: ${settings.name}');
  print('Route arguments: ${settings.arguments}');
  
  switch (settings.name) {
    case '/preferences':
      final imagePath = settings.arguments as String?;
      print('Navigating to preferences with image path: $imagePath');
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => PreferencesPage(),
      );
      
    case '/result':
      final imagePath = settings.arguments as String?;
      if (imagePath == null) {
        return _errorRoute("Missing image path for ResultPage.");
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => ResultPage(imagePath: imagePath),
      );

    case '/output':
      final args = settings.arguments as Map<String, dynamic>?;
      
      // Debug: Print the arguments received
      print('Output route arguments: $args');
      print('Output route arguments type: ${args?.runtimeType}');
      
      if (args == null) {
        print('No arguments received in output route');
        return MaterialPageRoute(
          builder: (context) => ImageResultPage(
            imagePath: 'assets/placeholder.jpg',
            skinTone: 'Fair',
            undertone: 'Neutral',
            modelService: modelService,
          ),
        );
      }
      
      print('Arguments keys: ${args.keys}');
      print('Preferences in args: ${args['preferences']}');
      
      return MaterialPageRoute(
        builder: (context) => ImageResultPage(
          imagePath: args['imagePath'] ?? 'assets/placeholder.jpg',
          skinTone: args['skinTone'] ?? 'Fair',
          undertone: args['undertone'] ?? 'Neutral',
          modelService: modelService,
          preferences: args['preferences'] as Map<String, bool>?, // Add preferences
        ),
      );

    case '/productinfo':
      // You can optionally extract arguments like:
      // final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(builder: (context) => const ProductInfoPage());

    default:
      return _errorRoute("Route not found: ${settings.name}");
  }
}

/// Error page fallback
Route<dynamic> _errorRoute(String message) {
  return MaterialPageRoute(
    builder: (context) => Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: const Text("Error")),
      body: Center(child: Text(message, style: const TextStyle(fontSize: 18))),
    ),
  );
}