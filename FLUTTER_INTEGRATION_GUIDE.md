# Flutter Integration Guide for TFLite Models

This guide explains how to integrate the converted TensorFlow Lite models into your Flutter application for skin tone and undertone detection.

## Prerequisites

1. Successfully converted H5 models to TFLite format
2. Flutter SDK installed
3. Android Studio or VS Code with Flutter extensions

## Setup

### 1. Add Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  tflite_flutter: ^0.10.4
  image: ^3.0.1
```

### 2. Add Model Assets

Create an assets directory structure and add your TFLite models:

```
assets/
└── models/
    ├── skintone_model.tflite
    └── undertone_model.tflite
```

Update your `pubspec.yaml` to include the models:

```yaml
flutter:
  assets:
    - assets/models/skintone_model.tflite
    - assets/models/undertone_model.tflite
```

### 3. Create Model Service

Create a new file `lib/services/model_service.dart`:

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelService {
  Interpreter? _skinToneInterpreter;
  Interpreter? _underToneInterpreter;

  // Load the models
  Future<void> loadModels() async {
    try {
      _skinToneInterpreter = await Interpreter.fromAsset(
        'assets/models/skintone_model.tflite',
      );
      
      _underToneInterpreter = await Interpreter.fromAsset(
        'assets/models/undertone_model.tflite',
      );
      
      print('Models loaded successfully');
    } catch (e) {
      print('Error loading models: $e');
    }
  }

  // Preprocess image for model input
  Float32List preprocessImage(File imageFile, int inputSize) {
    // Read image file
    final bytes = imageFile.readAsBytesSync();
    
    // Decode image
    final image = img.decodeImage(bytes)!;
    
    // Resize image to model input size (typically 224x224 for MobileNet)
    final resizedImage = img.copyResize(image, width: inputSize, height: inputSize);
    
    // Convert to Float32List
    final input = Float32List(inputSize * inputSize * 3);
    int index = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        // Normalize pixel values to [0, 1] range
        input[index++] = (img.getRed(pixel) / 255.0);
        input[index++] = (img.getGreen(pixel) / 255.0);
        input[index++] = (img.getBlue(pixel) / 255.0);
      }
    }
    
    return input;
  }

  // Run skin tone prediction
  List<double>? predictSkinTone(File imageFile) {
    if (_skinToneInterpreter == null) return null;
    
    try {
      // Get input tensor dimensions
      final inputShape = _skinToneInterpreter!.getInputTensor(0).shape;
      final inputSize = inputShape[1]; // Assuming square input
      
      // Preprocess image
      final input = preprocessImage(imageFile, inputSize);
      
      // Prepare output tensor
      final outputShape = _skinToneInterpreter!.getOutputTensor(0).shape;
      final output = List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);
      
      // Run inference
      _skinToneInterpreter!.run([input], output);
      
      // Return prediction results
      return output[0].cast<double>();
    } catch (e) {
      print('Error predicting skin tone: $e');
      return null;
    }
  }

  // Run undertone prediction
  List<double>? predictUnderTone(File imageFile) {
    if (_underToneInterpreter == null) return null;
    
    try {
      // Get input tensor dimensions
      final inputShape = _underToneInterpreter!.getInputTensor(0).shape;
      final inputSize = inputShape[1]; // Assuming square input
      
      // Preprocess image
      final input = preprocessImage(imageFile, inputSize);
      
      // Prepare output tensor
      final outputShape = _underToneInterpreter!.getOutputTensor(0).shape;
      final output = List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);
      
      // Run inference
      _underToneInterpreter!.run([input], output);
      
      // Return prediction results
      return output[0].cast<double>();
    } catch (e) {
      print('Error predicting undertone: $e');
      return null;
    }
  }

  // Get skin tone label from prediction
  String getSkinToneLabel(List<double> prediction) {
    // Define your skin tone labels based on your model's output
    final labels = ['Fair', 'Light', 'Medium', 'Olive', 'Brown', 'Dark'];
    
    // Find the index with maximum probability
    final maxIndex = prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));
    
    return labels[maxIndex];
  }

  // Get undertone label from prediction
  String getUnderToneLabel(List<double> prediction) {
    // Define your undertone labels based on your model's output
    final labels = ['Cool', 'Warm', 'Neutral'];
    
    // Find the index with maximum probability
    final maxIndex = prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));
    
    return labels[maxIndex];
  }

  // Dispose interpreters to free resources
  void dispose() {
    _skinToneInterpreter?.close();
    _underToneInterpreter?.close();
  }
}
```

## Usage in Your App

### 1. Initialize the Model Service

In your main.dart or a suitable initialization point:

```dart
import 'package:kikay_app/services/model_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize model service
  final modelService = ModelService();
  await modelService.loadModels();
  
  runApp(MyApp(modelService: modelService));
}
```

### 2. Use in Your Results Page

Update your `lib/screens/output.dart` to use the model predictions:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kikay_app/services/model_service.dart';

class ImageResultPage extends StatefulWidget {
  final String imagePath;
  final ModelService modelService;

  const ImageResultPage({
    super.key,
    required this.imagePath,
    required this.modelService,
  });

  @override
  State<ImageResultPage> createState() => _ImageResultPageState();
}

class _ImageResultPageState extends State<ImageResultPage> {
  String? skinTone;
  String? undertone;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final imageFile = File(widget.imagePath);
      
      // Predict skin tone
      final skinTonePrediction = widget.modelService.predictSkinTone(imageFile);
      if (skinTonePrediction != null) {
        skinTone = widget.modelService.getSkinToneLabel(skinTonePrediction);
      }
      
      // Predict undertone
      final undertonePrediction = widget.modelService.predictUnderTone(imageFile);
      if (undertonePrediction != null) {
        undertone = widget.modelService.getUnderToneLabel(undertonePrediction);
      }
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error analyzing image: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAsset = imagePath.startsWith('assets/');
    final fileExists = isAsset ? true : File(imagePath).existsSync();

    return Scaffold(
      backgroundColor: const Color(0xFFF4BBD3),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                children: [
                  
                  Text(
                    'Analysis Results',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFFDC1768),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Detected Skin Tone: ${skinTone ?? "Not detected"}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF970B45),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Detected Undertone: ${undertone ?? "Not detected"}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF970B45),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // ... rest of your existing code ...
                ],
              ),
      ),
    );
  }
}
```

## Model Output Interpretation

### Skin Tone Model
The skin tone model outputs probabilities for different skin tone categories:
- Index 0: Fair
- Index 1: Light
- Index 2: Medium
- Index 3: Olive
- Index 4: Brown
- Index 5: Dark

### Undertone Model
The undertone model outputs probabilities for undertone categories:
- Index 0: Cool
- Index 1: Warm
- Index 2: Neutral

## Error Handling

Common issues and solutions:

1. **Model loading fails**: Check that the model files are in the correct assets directory and declared in pubspec.yaml
2. **Inference errors**: Ensure image preprocessing matches the model's expected input format
3. **Memory issues**: Dispose of interpreters properly when not needed

## Performance Optimization

1. Load models once at app startup
2. Reuse interpreters instead of creating new ones
3. Preprocess images efficiently
4. Run inference on background threads for better UI responsiveness

## Testing

Test your implementation with various images to ensure:
1. Models load correctly
2. Predictions are accurate
3. Error handling works properly
4. Performance is acceptable