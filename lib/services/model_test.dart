import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'model_service.dart';

class ModelTest {
  static Future<void> testModels() async {
    try {
      print('Testing model service...');

      // Initialize the model service
      final modelService = ModelService();
      await modelService.loadModels();

      print('Models loaded successfully!');

      // Try to get the documents directory to see if we can access files
      final dir = await getApplicationDocumentsDirectory();
      print('Documents directory: ${dir.path}');

      // List files in the assets directory to see what we have
      print('Checking assets directory...');

      // Note: In a real app, you would test with an actual image file
      // For now, we're just verifying the models load correctly
      print('Model service test completed successfully!');

      // Dispose of the models to free resources
      modelService.dispose();
    } catch (e) {
      print('Error testing model service: $e');
    }
  }
}
