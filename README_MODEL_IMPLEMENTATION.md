# Kikay Model Implementation

This document explains how to use the TensorFlow Lite models for skin tone and undertone detection in the Kikay app.

## Overview

The implementation uses two TensorFlow Lite models:
1. **Skin Tone Model**: Detects skin tone (Fair, Light, Medium, Olive, Brown, Dark)
2. **Undertone Model**: Detects undertone (Cool, Warm, Neutral)

## How It Works

### 1. Model Loading
Models are loaded automatically when the app starts in `main.dart`:

```dart
modelService = ModelService();
await modelService.loadModels();
```

### 2. Image Processing Flow
1. User captures or selects an image
2. Image path is passed through the navigation flow
3. Output screen runs predictions on the image
4. Results are displayed to the user

### 3. Prediction Process
The models expect 224x224 RGB images with pixel values normalized to [0, 1].

## Key Files

### `lib/services/model_service.dart`
Main service for model operations:
- Loading models from assets
- Preprocessing images
- Running predictions
- Converting results to labels

### `lib/screens/output.dart`
Screen that displays model predictions:
- Receives image path and ModelService
- Runs predictions when loaded
- Shows results to user

### `lib/routes.dart`
Handles navigation and passes ModelService to screens.

## Testing the Implementation

### 1. Run the App
```bash
flutter run
```

### 2. Navigate Through the App
1. Follow the splash/welcome flow
2. Use the camera to capture an image or select from gallery
3. Proceed through preferences
4. View predictions in the output screen

### 3. Check Console Output
Look for these messages:
- "Models loaded successfully"
- Prediction results
- Any error messages

## Dependencies

The implementation uses these packages:
- `tflite_flutter`: For running TensorFlow Lite models
- `image`: For image preprocessing

## Model Details

### Skin Tone Model
- **File**: `assets/mobilenet_skintone_final.tflite`
- **Architecture**: MobileNetV2
- **Input**: 224x224 RGB image
- **Output**: 6-class probabilities

### Undertone Model
- **File**: `assets/mobilenet_undertone_final.tflite`
- **Architecture**: MobileNetV2
- **Input**: 224x224 RGB image
- **Output**: 3-class probabilities

## Troubleshooting

### Models Not Loading
1. Check that TFLite files are in the assets folder
2. Verify asset declarations in `pubspec.yaml`
3. Run `flutter pub get` to update dependencies

### Predictions Not Appearing
1. Check console for error messages
2. Verify image file exists and is readable
3. Ensure ModelService is properly passed to output screen

### Performance Issues
1. Models are large (~2.7MB each)
2. First prediction may be slow due to initialization
3. Subsequent predictions should be faster

## Extending the Implementation

### Adding New Models
1. Add TFLite file to assets folder
2. Update `pubspec.yaml` asset declarations
3. Modify ModelService to load new model
4. Add prediction methods
5. Update UI to display new results

### Improving Accuracy
1. Retrain models with more diverse data
2. Experiment with different preprocessing techniques
3. Try different model architectures
4. Implement model ensembling

### Adding Error Handling
1. Add specific error types for different failure modes
2. Implement retry mechanisms
3. Add user-friendly error messages
4. Provide fallback options