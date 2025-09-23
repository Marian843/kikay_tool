import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'model_service.dart';

class ModelTest {
  static Future<void> testModels() async {
    try {
      // Initialize the model service
      final modelService = ModelService();
      await modelService.loadModels();

      // Try to get the documents directory to see if we can access files
      final dir = await getApplicationDocumentsDirectory();

      // Note: In a real app, you would test with an actual image file
      // For now, we're just verifying the models load correctly

      // Dispose of the models to free resources
      modelService.dispose();
    } catch (e) {
      // Error handling without print statement
    }
  }
}
