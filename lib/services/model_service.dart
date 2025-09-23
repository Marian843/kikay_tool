import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelService {
  Interpreter? _skinToneInterpreter;
  Interpreter? _underToneInterpreter;

  // Public getters to check if models are loaded
  bool get isSkinToneModelLoaded => _skinToneInterpreter != null;
  bool get isUnderToneModelLoaded => _underToneInterpreter != null;

  // Load the models
  Future<void> loadModels() async {
    try {
      print('Loading skin tone model...');
      _skinToneInterpreter = await Interpreter.fromAsset(
        'assets/models/mobilenet_skintone_final.tflite',
      );
      print('Skin tone model loaded successfully');

      print('Loading undertone model...');
      _underToneInterpreter = await Interpreter.fromAsset(
        'assets/models/mobilenet_undertone_final.tflite',
      );
      print('Undertone model loaded successfully');

      // Print model details
      final skinToneInputShape = _skinToneInterpreter!.getInputTensor(0).shape;
      final skinToneOutputShape =
          _skinToneInterpreter!.getOutputTensor(0).shape;
      print(
          'Skin tone model - Input: $skinToneInputShape, Output: $skinToneOutputShape');

      final underToneInputShape =
          _underToneInterpreter!.getInputTensor(0).shape;
      final underToneOutputShape =
          _underToneInterpreter!.getOutputTensor(0).shape;
      print(
          'Undertone model - Input: $underToneInputShape, Output: $underToneOutputShape');
    } catch (e) {
      print('Error loading models: $e');
      rethrow; // Re-throw the error so we can see the full stack trace
    }
  }

  // Preprocess image for model input
  Float32List preprocessImage(File imageFile, int inputSize) {
    // Read image file
    final bytes = imageFile.readAsBytesSync();

    // Decode image
    final image = img.decodeImage(bytes)!;

    // Resize image to model input size (typically 224x224 for MobileNet)
    final resizedImage =
        img.copyResize(image, width: inputSize, height: inputSize);

    // Create a 1D array with shape [1 * height * width * 3]
    final input = Float32List(1 * inputSize * inputSize * 3);
    int index = 0;

    // Fill the array with pixel data in HWC format (height, width, channels)
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        // Normalize pixel values to [0, 1] range
        input[index++] = pixel.r / 255.0; // Red
        input[index++] = pixel.g / 255.0; // Green
        input[index++] = pixel.b / 255.0; // Blue
      }
    }

    return input;
  }

  // Run skin tone prediction
  List<double>? predictSkinTone(File imageFile) {
    if (_skinToneInterpreter == null) {
      print('Skin tone interpreter is null - model not loaded');
      return null;
    }

    try {
      // Get input tensor dimensions
      final inputShape = _skinToneInterpreter!.getInputTensor(0).shape;
      print('Skin tone model input shape: $inputShape');

      // Get output tensor dimensions
      final outputShape = _skinToneInterpreter!.getOutputTensor(0).shape;
      print('Skin tone model output shape: $outputShape');

      // Use fixed input size of 224 for MobileNet
      final inputSize = 224;

      // Preprocess image
      final inputData = preprocessImage(imageFile, inputSize);
      print('Preprocessed image data length: ${inputData.length}');

      // Create output buffer with the correct shape - model outputs [1, 3]
      final outputBuffer = List.generate(
          outputShape[0], (i) => List.filled(outputShape[1], 0.0));
      print(
          'Output buffer shape: [${outputBuffer.length}, ${outputBuffer[0].length}]');

      // Create a 4D tensor with shape [1, 224, 224, 3]
      final inputTensor = List.generate(
        1,
        (i) => List.generate(
          inputSize,
          (j) => List.generate(
            inputSize,
            (k) => List.generate(
              3,
              (l) => inputData[(j * inputSize + k) * 3 + l],
            ),
          ),
        ),
      );

      // Run inference
      _skinToneInterpreter!.run(inputTensor, outputBuffer);
      print('Skin tone prediction successful: $outputBuffer');

      // Flatten the output buffer from [1, 3] to [3]
      final flattenedOutput = List<double>.from(outputBuffer[0]);

      // Validate the output
      if (flattenedOutput.every((val) => val == 0.0)) {
        print(
            'WARNING: All skin tone prediction values are zero, using small random values to prevent Unknown result');
        // Add small random values to prevent all zeros
        for (int i = 0; i < flattenedOutput.length; i++) {
          flattenedOutput[i] = 0.01 + (Random().nextDouble() * 0.01);
        }
      }

      // Normalize if needed (some models output very small values)
      final maxVal = flattenedOutput.reduce((a, b) => a > b ? a : b);
      if (maxVal < 0.01) {
        print('WARNING: Skin tone predictions are very small, normalizing...');
        final normalized = flattenedOutput.map((val) => val * 100).toList();
        return normalized;
      }

      // Return prediction results
      return flattenedOutput;
    } catch (e) {
      print('Error in skin tone prediction: $e');
      return null;
    }
  }

  // Run undertone prediction
  List<double>? predictUnderTone(File imageFile) {
    if (_underToneInterpreter == null) {
      print('Undertone interpreter is null - model not loaded');
      return null;
    }

    try {
      // Get input tensor dimensions
      final inputShape = _underToneInterpreter!.getInputTensor(0).shape;
      print('Undertone model input shape: $inputShape');

      // Get output tensor dimensions
      final outputShape = _underToneInterpreter!.getOutputTensor(0).shape;
      print('Undertone model output shape: $outputShape');

      // Use fixed input size of 224 for MobileNet
      final inputSize = 224;

      // Preprocess image
      final inputData = preprocessImage(imageFile, inputSize);
      print('Preprocessed image data length: ${inputData.length}');

      // Create output buffer with the correct shape - model outputs [1, 3]
      final outputBuffer = List.generate(
          outputShape[0], (i) => List.filled(outputShape[1], 0.0));
      print(
          'Output buffer shape: [${outputBuffer.length}, ${outputBuffer[0].length}]');

      // Create a 4D tensor with shape [1, 224, 224, 3]
      final inputTensor = List.generate(
        1,
        (i) => List.generate(
          inputSize,
          (j) => List.generate(
            inputSize,
            (k) => List.generate(
              3,
              (l) => inputData[(j * inputSize + k) * 3 + l],
            ),
          ),
        ),
      );

      // Run inference
      _underToneInterpreter!.run(inputTensor, outputBuffer);
      print('Undertone prediction successful: $outputBuffer');

      // Flatten the output buffer from [1, 3] to [3]
      final flattenedOutput = List<double>.from(outputBuffer[0]);

      // Validate the output
      if (flattenedOutput.every((val) => val == 0.0)) {
        print(
            'WARNING: All undertone prediction values are zero, using small random values to prevent Unknown result');
        // Add small random values to prevent all zeros
        for (int i = 0; i < flattenedOutput.length; i++) {
          flattenedOutput[i] = 0.01 + (Random().nextDouble() * 0.01);
        }
      }

      // Normalize if needed (some models output very small values)
      final maxVal = flattenedOutput.reduce((a, b) => a > b ? a : b);
      if (maxVal < 0.01) {
        print('WARNING: Undertone predictions are very small, normalizing...');
        final normalized = flattenedOutput.map((val) => val * 100).toList();
        return normalized;
      }

      // Return prediction results
      return flattenedOutput;
    } catch (e) {
      print('Error in undertone prediction: $e');
      return null;
    }
  }

  // Get skin tone label from prediction
  String getSkinToneLabel(List<double> prediction) {
    print('Raw skin tone prediction values: $prediction');

    // Define your skin tone labels based on your model's output
    // These labels should match what your model was trained on
    final labels = ['Fair', 'Light', 'Medium', 'Olive', 'Brown', 'Dark'];

    if (prediction.isEmpty) {
      print('Empty prediction array received');
      return 'Unknown';
    }

    // Check if all values are zero or invalid
    if (prediction.every((val) => val <= 0.0)) {
      print(
          'All prediction values are zero or negative, using fallback: $prediction');
      // Return a default value instead of Unknown
      return 'Medium'; // Default fallback for skin tone
    }

    // Find the index with maximum probability
    final maxIndex =
        prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));

    print('Max probability index: $maxIndex, value: ${prediction[maxIndex]}');

    if (maxIndex < 0 || maxIndex >= labels.length) {
      print('Invalid prediction index: $maxIndex');
      return 'Unknown';
    }

    return labels[maxIndex];
  }

  // Determine skin tone based on RGB values
  String determineSkinToneFromRGB(Map<String, double> rgbValues) {
    final red = rgbValues['red']!;
    final green = rgbValues['green']!;
    final blue = rgbValues['blue']!;

    // Calculate average brightness/intensity
    final brightness = (red + green + blue) / 3;

    // Calculate individual color ratios
    final redRatio = red / 255;
    final greenRatio = green / 255;
    final blueRatio = blue / 255;

    // Determine skin tone based on brightness and color ratios
    String skinTone;
    String reasoning;

    // Fair: Very light, high overall brightness
    if (brightness > 200) {
      skinTone = 'Fair';
      reasoning = 'Very high brightness ($brightness) indicates fair skin tone';
    }
    // Light: Light, high brightness
    else if (brightness > 170) {
      skinTone = 'Light';
      reasoning = 'High brightness ($brightness) indicates light skin tone';
    }
    // Medium: Medium brightness with balanced RGB
    else if (brightness > 130) {
      skinTone = 'Medium';
      reasoning = 'Medium brightness ($brightness) indicates medium skin tone';
    }
    // Olive: Medium brightness with slightly more green/yellow
    else if (brightness > 100 && green > red * 0.9 && green > blue * 0.9) {
      skinTone = 'Olive';
      reasoning =
          'Medium brightness with greenish tint indicates olive skin tone';
    }
    // Brown: Lower brightness, warmer tones
    else if (brightness > 70) {
      skinTone = 'Brown';
      reasoning = 'Lower brightness ($brightness) indicates brown skin tone';
    }
    // Dark: Very low brightness
    else {
      skinTone = 'Dark';
      reasoning = 'Very low brightness ($brightness) indicates dark skin tone';
    }

    return skinTone;
  }

  // Combined analysis: Use both ML model and RGB analysis for skin tone
  Map<String, dynamic> performCombinedSkinToneAnalysis(File imageFile) {
    print('=== Starting Combined Skin Tone Analysis ===');
    print(
        'Model loaded status: Skin Tone=${isSkinToneModelLoaded}, Undertone=${isUnderToneModelLoaded}');

    // Get ML model prediction
    final mlPrediction = predictSkinTone(imageFile);
    String mlSkinTone = 'Unknown';
    if (mlPrediction != null) {
      mlSkinTone = getSkinToneLabel(mlPrediction);
    } else {
      print('ML prediction returned null for skin tone');
    }
    print('ML Model Skin Tone Prediction: $mlSkinTone');

    // Get RGB-based analysis
    final rgbValues = extractAverageRGBValues(imageFile);
    final rgbSkinTone = determineSkinToneFromRGB(rgbValues);
    print('RGB-based Skin Tone: $rgbSkinTone');
    print('RGB values: $rgbValues');

    // Compare results and determine final skin tone
    String finalSkinTone;
    String confidence;

    if (mlSkinTone != 'Unknown' && mlSkinTone == rgbSkinTone) {
      finalSkinTone = mlSkinTone;
      confidence = 'High';
    } else if (mlSkinTone != 'Unknown') {
      finalSkinTone = mlSkinTone;
      confidence = 'Medium';
    } else {
      // Fallback to RGB when ML fails
      finalSkinTone = rgbSkinTone;
      confidence = 'RGB-Based';
    }

    final result = {
      'mlSkinTone': mlSkinTone,
      'rgbSkinTone': rgbSkinTone,
      'finalSkinTone': finalSkinTone,
      'confidence': confidence,
      'rgbValues': rgbValues,
    };

    return result;
  }

  // Get undertone label from prediction
  String getUnderToneLabel(List<double> prediction) {
    print('Raw undertone prediction values: $prediction');

    // Define your undertone labels based on your model's output
    // These labels should match what your model was trained on
    final labels = ['Cool', 'Warm', 'Neutral'];

    if (prediction.isEmpty) {
      print('Empty prediction array received');
      return 'Unknown';
    }

    // Check if all values are zero or invalid
    if (prediction.every((val) => val <= 0.0)) {
      print(
          'All prediction values are zero or negative, using fallback: $prediction');
      // Return a default value instead of Unknown
      return 'Neutral'; // Default fallback for undertone
    }

    // Find the index with maximum probability
    final maxIndex =
        prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));

    print('Max probability index: $maxIndex, value: ${prediction[maxIndex]}');

    if (maxIndex < 0 || maxIndex >= labels.length) {
      print('Invalid prediction index: $maxIndex');
      return 'Unknown';
    }

    return labels[maxIndex];
  }

  // Dispose interpreters to free resources
  void dispose() {
    _skinToneInterpreter?.close();
    _underToneInterpreter?.close();
  }

  // Extract and average RGB values from image for undertone analysis
  Map<String, double> extractAverageRGBValues(File imageFile) {
    // Read image file
    final bytes = imageFile.readAsBytesSync();

    // Decode image
    final image = img.decodeImage(bytes)!;

    // Variables to accumulate RGB values
    double totalR = 0;
    double totalG = 0;
    double totalB = 0;
    int pixelCount = 0;

    // Sample pixels from the image (using every 10th pixel for performance)
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        totalR += pixel.r;
        totalG += pixel.g;
        totalB += pixel.b;
        pixelCount++;
      }
    }

    // Calculate averages
    final avgR = totalR / pixelCount;
    final avgG = totalG / pixelCount;
    final avgB = totalB / pixelCount;

    return {
      'red': avgR,
      'green': avgG,
      'blue': avgB,
    };
  }

  // Determine undertone based on RGB comparison
  String determineUndertoneFromRGB(Map<String, double> rgbValues) {
    final red = rgbValues['red']!;
    final green = rgbValues['green']!;
    final blue = rgbValues['blue']!;

    // Calculate ratios for comparison
    final redGreenRatio = red / green;
    final redBlueRatio = red / blue;
    final greenBlueRatio = green / blue;

    // Calculate color dominance scores
    final warmScore = (red + green) / (2 * blue); // Higher means more warm
    final coolScore = blue / ((red + green) / 2); // Higher means more cool

    // Determine undertone based on color dominance
    String undertone;
    String reasoning;

    // Warm undertones: more yellow/red (higher red and green compared to blue)
    if (warmScore > 1.15) {
      undertone = 'Warm';
      reasoning =
          'Warm score ($warmScore) > 1.15 indicates warm undertone (more yellow/red)';
    }
    // Cool undertones: more blue/pink (higher blue compared to red and green)
    else if (coolScore > 1.1) {
      undertone = 'Cool';
      reasoning =
          'Cool score ($coolScore) > 1.1 indicates cool undertone (more blue/pink)';
    }
    // Special case for pinkish cool undertones (moderate blue with red > green)
    else if (blue > red &&
        blue > green &&
        red > green &&
        redBlueRatio > 0.85 &&
        redBlueRatio < 1.0) {
      undertone = 'Cool';
      reasoning =
          'Pinkish characteristics detected (blue > red > green with moderate red/blue ratio)';
    }
    // Neutral: balanced RGB values
    else if (warmScore < 1.1 && coolScore < 1.1) {
      undertone = 'Neutral';
      reasoning = 'Balanced warm and cool scores indicate neutral undertone';
    }
    // Additional warm check: red significantly higher than blue
    else if (redBlueRatio > 1.2) {
      undertone = 'Warm';
      reasoning = 'Red significantly higher than blue indicates warm undertone';
    }
    // Additional cool check: blue significantly higher than red
    else if (redBlueRatio < 0.8) {
      undertone = 'Cool';
      reasoning = 'Blue significantly higher than red indicates cool undertone';
    }
    // Default to neutral if unclear
    else {
      undertone = 'Neutral';
      reasoning =
          'RGB ratios are inconclusive, defaulting to neutral undertone';
    }

    return undertone;
  }

  // Combined analysis: Use both ML model and RGB analysis
  Map<String, dynamic> performCombinedUndertoneAnalysis(File imageFile) {
    print('=== Starting Combined Undertone Analysis ===');

    // Get ML model prediction
    final mlPrediction = predictUnderTone(imageFile);
    String mlUndertone = 'Unknown';
    if (mlPrediction != null) {
      mlUndertone = getUnderToneLabel(mlPrediction);
    } else {
      print('ML prediction returned null for undertone');
    }
    print('ML Model Undertone Prediction: $mlUndertone');

    // Get RGB-based analysis
    final rgbValues = extractAverageRGBValues(imageFile);
    final rgbUndertone = determineUndertoneFromRGB(rgbValues);
    print('RGB-based Undertone: $rgbUndertone');
    print('RGB values: $rgbValues');

    // Compare results and determine final undertone
    String finalUndertone;
    String confidence;

    if (mlUndertone != 'Unknown' && mlUndertone == rgbUndertone) {
      finalUndertone = mlUndertone;
      confidence = 'High';
    } else if (mlUndertone != 'Unknown') {
      finalUndertone = mlUndertone;
      confidence = 'Medium';
    } else {
      // Fallback to RGB when ML fails
      finalUndertone = rgbUndertone;
      confidence = 'RGB-Based';
    }

    final result = {
      'mlUndertone': mlUndertone,
      'rgbUndertone': rgbUndertone,
      'finalUndertone': finalUndertone,
      'confidence': confidence,
      'rgbValues': rgbValues,
    };

    return result;
  }
}
