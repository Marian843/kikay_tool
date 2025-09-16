// Test script to verify model loading
import 'package:flutter/material.dart';
import 'lib/services/model_service.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Model Loading Test')),
        body: const ModelLoadingTest(),
      ),
    );
  }
}

class ModelLoadingTest extends StatefulWidget {
  const ModelLoadingTest({super.key});

  @override
  State<ModelLoadingTest> createState() => _ModelLoadingTestState();
}

class _ModelLoadingTestState extends State<ModelLoadingTest> {
  String _status = 'Initializing...';
  bool _modelsLoaded = false;

  @override
  void initState() {
    super.initState();
    _testModelLoading();
  }

  Future<void> _testModelLoading() async {
    setState(() {
      _status = 'Loading models...';
    });

    try {
      final modelService = ModelService();
      await modelService.loadModels();

      setState(() {
        _status = 'Models loaded successfully!';
        _modelsLoaded = true;
      });

      // Check if models are actually loaded
      if (modelService.isSkinToneModelLoaded) {
        setState(() {
          _status += '\n✓ Skin tone model loaded';
        });
      } else {
        setState(() {
          _status += '\n✗ Skin tone model failed to load';
        });
      }

      if (modelService.isUnderToneModelLoaded) {
        setState(() {
          _status += '\n✓ Undertone model loaded';
        });
      } else {
        setState(() {
          _status += '\n✗ Undertone model failed to load';
        });
      }

      // Clean up
      modelService.dispose();
    } catch (e) {
      setState(() {
        _status = 'Error loading models: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _status,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          if (!_modelsLoaded)
            const CircularProgressIndicator()
          else
            const Icon(Icons.check, color: Colors.green, size: 50),
        ],
      ),
    );
  }
}
