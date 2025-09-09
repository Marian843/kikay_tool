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
  '/preferences': (context) {
    final imagePath = ModalRoute.of(context)?.settings.arguments as String?;
    return PreferencesPage(
      onPressed: () => Navigator.pushNamed(
        context,
        '/output',
        arguments: {
          'imagePath': imagePath,
          'skinTone': 'Fair',
          'undertone': 'Neutral',
        },
      ),
    );
  },
};

/// Dynamic route generator for routes with arguments
Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
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
      if (args == null) {
        return MaterialPageRoute(
          builder: (context) => ImageResultPage(
            imagePath: 'assets/placeholder.jpg',
            skinTone: 'Fair',
            undertone: 'Neutral',
          ),
        );
      }
      return MaterialPageRoute(
        builder: (context) => ImageResultPage(
          imagePath: args['imagePath'] ?? 'assets/placeholder.jpg',
          skinTone: args['skinTone'] ?? 'Fair',
          undertone: args['undertone'] ?? 'Neutral',
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
