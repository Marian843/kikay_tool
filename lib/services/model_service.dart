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
}
