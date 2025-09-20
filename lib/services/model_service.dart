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
      print('Attempting to load skin tone model...');
      _skinToneInterpreter = await Interpreter.fromAsset(
        'assets/models/mobilenet_skintone_final.tflite',
      );
      print('Skin tone model loaded successfully');

      print('Attempting to load undertone model...');
      _underToneInterpreter = await Interpreter.fromAsset(
        'assets/models/mobilenet_undertone_final.tflite',
      );
      print('Undertone model loaded successfully');

      print('Models loaded successfully');
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

    print('Preprocessed image data length: ${input.length}');
    print('Expected input size: ${1 * inputSize * inputSize * 3}');

    return input;
  }

  // Run skin tone prediction
  List<double>? predictSkinTone(File imageFile) {
    if (_skinToneInterpreter == null) {
      print('Skin tone interpreter not loaded');
      return null;
    }

    try {
      // Get input tensor dimensions
      final inputShape = _skinToneInterpreter!.getInputTensor(0).shape;
      print('Skin tone model input shape: $inputShape');

      // Use fixed input size of 224 for MobileNet
      final inputSize = 224;
      print('Using input size: $inputSize');

      // Preprocess image
      final inputData = preprocessImage(imageFile, inputSize);

      // Log input data info
      print('Input data length: ${inputData.length}');
      print(
          'First few values: ${inputData.sublist(0, min(10, inputData.length))}');

      // Prepare output tensor with correct shape [1, 3] to match model output
      final outputShape = _skinToneInterpreter!.getOutputTensor(0).shape;
      print('Skin tone model output shape: $outputShape');

      // Create output buffer with the correct shape (should be [1, 3])
      final outputBuffer = List.filled(outputShape[0] * outputShape[1], 0.0);

      // Create a 4D tensor with shape [1, 224, 224, 3] instead of 1D array
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

      // Return prediction results
      return outputBuffer;
    } catch (e) {
      print('Error predicting skin tone: $e');
      return null;
    }
  }

  // Run undertone prediction
  List<double>? predictUnderTone(File imageFile) {
    if (_underToneInterpreter == null) {
      print('Undertone interpreter not loaded');
      return null;
    }

    try {
      // Get input tensor dimensions
      final inputShape = _underToneInterpreter!.getInputTensor(0).shape;
      print('Undertone model input shape: $inputShape');

      // Use fixed input size of 224 for MobileNet
      final inputSize = 224;
      print('Using input size: $inputSize');

      // Preprocess image
      final inputData = preprocessImage(imageFile, inputSize);

      // Log input data info
      print('Input data length: ${inputData.length}');
      print(
          'First few values: ${inputData.sublist(0, min(10, inputData.length))}');

      // Prepare output tensor with correct shape [1, 3] to match model output
      final outputShape = _underToneInterpreter!.getOutputTensor(0).shape;
      print('Undertone model output shape: $outputShape');

      // Create output buffer with the correct shape (should be [1, 3])
      final outputBuffer = List.filled(outputShape[0] * outputShape[1], 0.0);

      // Create a 4D tensor with shape [1, 224, 224, 3] instead of 1D array
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

      // Return prediction results
      return outputBuffer;
    } catch (e) {
      print('Error predicting undertone: $e');
      return null;
    }
  }

  // Get skin tone label from prediction
  String getSkinToneLabel(List<double> prediction) {
    // Define your skin tone labels based on your model's output
    // These labels should match what your model was trained on
    final labels = ['Fair', 'Light', 'Medium', 'Olive', 'Brown', 'Dark'];

    // Find the index with maximum probability
    final maxIndex =
        prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));

    return labels[maxIndex];
  }

  // Determine skin tone based on RGB values
  String determineSkinToneFromRGB(Map<String, double> rgbValues) {
    final red = rgbValues['red']!;
    final green = rgbValues['green']!;
    final blue = rgbValues['blue']!;

    print('Analyzing RGB values for skin tone determination...');
    print('Red: $red, Green: $green, Blue: $blue');

    // Calculate average brightness/intensity
    final brightness = (red + green + blue) / 3;
    
    // Calculate individual color ratios
    final redRatio = red / 255;
    final greenRatio = green / 255;
    final blueRatio = blue / 255;
    
    print('Brightness: $brightness');
    print('Red ratio: $redRatio, Green ratio: $greenRatio, Blue ratio: $blueRatio');

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
      reasoning = 'Medium brightness with greenish tint indicates olive skin tone';
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

    print('Skin Tone Analysis Result:');
    print('Detected Skin Tone: $skinTone');
    print('Reasoning: $reasoning');

    return skinTone;
  }

  // Combined analysis: Use both ML model and RGB analysis for skin tone
  Map<String, dynamic> performCombinedSkinToneAnalysis(File imageFile) {
    print('=== COMBINED SKIN TONE ANALYSIS ===');

    // Get ML model prediction
    final mlPrediction = predictSkinTone(imageFile);
    String mlSkinTone = 'Unknown';
    if (mlPrediction != null) {
      mlSkinTone = getSkinToneLabel(mlPrediction);
    }
    print('ML Model Skin Tone Prediction: $mlSkinTone');

    // Get RGB-based analysis
    final rgbValues = extractAverageRGBValues(imageFile);
    final rgbSkinTone = determineSkinToneFromRGB(rgbValues);
    print('RGB-based Skin Tone: $rgbSkinTone');

    // Compare results and determine final skin tone
    String finalSkinTone;
    String confidence;

    if (mlSkinTone == rgbSkinTone) {
      finalSkinTone = mlSkinTone;
      confidence = 'High';
      print('Both ML and RGB analysis agree: $finalSkinTone');
    } else {
      // When they disagree, use RGB analysis as primary for this specific task
      finalSkinTone = rgbSkinTone;
      confidence = 'Medium';
      print('ML and RGB analysis disagree. ML: $mlSkinTone, RGB: $rgbSkinTone');
      print('Using RGB-based result as primary: $finalSkinTone');
    }

    final result = {
      'mlSkinTone': mlSkinTone,
      'rgbSkinTone': rgbSkinTone,
      'finalSkinTone': finalSkinTone,
      'confidence': confidence,
      'rgbValues': rgbValues,
    };

    print('=== FINAL SKIN TONE ANALYSIS RESULT ===');
    print('Final Skin Tone: ${result['finalSkinTone']}');
    print('Confidence: ${result['confidence']}');
    print('======================================');

    return result;
  }

  // Get undertone label from prediction
  String getUnderToneLabel(List<double> prediction) {
    // Define your undertone labels based on your model's output
    // These labels should match what your model was trained on
    final labels = ['Cool', 'Warm', 'Neutral'];

    // Find the index with maximum probability
    final maxIndex =
        prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));

    return labels[maxIndex];
  }

  // Dispose interpreters to free resources
  void dispose() {
    _skinToneInterpreter?.close();
    _underToneInterpreter?.close();
  }

  // Extract and average RGB values from image for undertone analysis
  Map<String, double> extractAverageRGBValues(File imageFile) {
    print('Starting RGB analysis for undertone determination...');

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

    print('RGB Analysis Results:');
    print('Average Red: $avgR');
    print('Average Green: $avgG');
    print('Average Blue: $avgB');
    print('Total pixels sampled: $pixelCount');

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

    print('Analyzing RGB values for undertone determination...');
    print('Red: $red, Green: $green, Blue: $blue');

    // Calculate ratios for comparison
    final redGreenRatio = red / green;
    final redBlueRatio = red / blue;
    final greenBlueRatio = green / blue;

    // Calculate color dominance scores
    final warmScore = (red + green) / (2 * blue); // Higher means more warm
    final coolScore = blue / ((red + green) / 2); // Higher means more cool

    print('RGB Ratios:');
    print('Red/Green: $redGreenRatio');
    print('Red/Blue: $redBlueRatio');
    print('Green/Blue: $greenBlueRatio');
    print('Warm Score: $warmScore');
    print('Cool Score: $coolScore');

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

    print('Undertone Analysis Result:');
    print('Detected Undertone: $undertone');
    print('Reasoning: $reasoning');

    return undertone;
  }

  // Combined analysis: Use both ML model and RGB analysis
  Map<String, dynamic> performCombinedUndertoneAnalysis(File imageFile) {
    print('=== COMBINED UNDERTONE ANALYSIS ===');

    // Get ML model prediction
    final mlPrediction = predictUnderTone(imageFile);
    String mlUndertone = 'Unknown';
    if (mlPrediction != null) {
      mlUndertone = getUnderToneLabel(mlPrediction);
    }
    print('ML Model Undertone Prediction: $mlUndertone');

    // Get RGB-based analysis
    final rgbValues = extractAverageRGBValues(imageFile);
    final rgbUndertone = determineUndertoneFromRGB(rgbValues);
    print('RGB-based Undertone: $rgbUndertone');

    // Compare results and determine final undertone
    String finalUndertone;
    String confidence;

    if (mlUndertone == rgbUndertone) {
      finalUndertone = mlUndertone;
      confidence = 'High';
      print('Both ML and RGB analysis agree: $finalUndertone');
    } else {
      // When they disagree, use RGB analysis as primary for this specific task
      finalUndertone = rgbUndertone;
      confidence = 'Medium';
      print(
          'ML and RGB analysis disagree. ML: $mlUndertone, RGB: $rgbUndertone');
      print('Using RGB-based result as primary: $finalUndertone');
    }

    final result = {
      'mlUndertone': mlUndertone,
      'rgbUndertone': rgbUndertone,
      'finalUndertone': finalUndertone,
      'confidence': confidence,
      'rgbValues': rgbValues,
    };

    print('=== FINAL UNDERTONE ANALYSIS RESULT ===');
    print('Final Undertone: ${result['finalUndertone']}');
    print('Confidence: ${result['confidence']}');
    print('=====================================');

    return result;
  }
}
