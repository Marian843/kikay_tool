# Model Implementation Guide

This guide explains how the TensorFlow Lite models have been implemented in the Kikay app for skin tone and undertone detection.

## Overview

The implementation consists of:
1. Two TensorFlow Lite models for skin tone and undertone detection
2. A ModelService class that handles loading and running the models
3. Integration with the app's UI to display predictions

## File Structure

```
lib/
├── services/
│   ├── model_service.dart      # Main model service implementation
│   └── model_test.dart         # Testing utilities
├── screens/
│   ├── output.dart             # Updated to use model predictions
│   └── preferences.dart        # Updated to pass image path
└── routes.dart                 # Updated to pass model service
```

## Model Service Implementation

The `ModelService` class in `lib/services/model_service.dart` provides:

1. **Model Loading**: Loads the TFLite models from assets
2. **Image Preprocessing**: Converts images to the format expected by the models
3. **Prediction**: Runs inference on the models
4. **Label Mapping**: Converts model outputs to human-readable labels

### Key Methods

- `loadModels()`: Loads both skin tone and undertone models
- `predictSkinTone(File imageFile)`: Runs skin tone prediction
- `predictUnderTone(File imageFile)`: Runs undertone prediction
- `getSkinToneLabel(List<double> prediction)`: Maps prediction to skin tone label
- `getUnderToneLabel(List<double> prediction)`: Maps prediction to undertone label

## Data Flow

1. User captures/selects an image in the camera screen
2. Image path is passed through the navigation flow:
   - `/camera` → `/result` → `/preferences` → `/output`
3. In the output screen, the image is processed by the models
4. Predictions are displayed to the user

## Model Integration Points

### main.dart
- Initializes the ModelService when the app starts
- Makes the service globally available

### routes.dart
- Passes the ModelService to the output screen

### output.dart
- Receives the ModelService and image path
- Runs predictions when the screen loads
- Displays results in the UI

## Model Details

### Skin Tone Model
- **File**: `assets/mobilenet_skintone_final.tflite`
- **Input**: 224x224 RGB image
- **Output**: 6-class probability distribution
- **Labels**: Fair, Light, Medium, Olive, Brown, Dark

### Undertone Model
- **File**: `assets/mobilenet_undertone_final.tflite`
- **Input**: 224x224 RGB image
- **Output**: 3-class probability distribution
- **Labels**: Cool, Warm, Neutral

## Image Preprocessing

The models expect 224x224 RGB images with pixel values normalized to [0, 1]. The preprocessing steps are:

1. Load image file as bytes
2. Decode image using the `image` package
3. Resize to 224x224 pixels
4. Extract RGB values and normalize to [0, 1] range
5. Convert to Float32List for model input

## Error Handling

The implementation includes error handling for:
- Model loading failures
- Image processing errors
- Prediction failures
- Missing image files

## Performance Considerations

- Models are loaded once at app startup
- Interpreters are reused for multiple predictions
- Resources are freed when no longer needed
- Predictions run asynchronously to avoid blocking the UI

## Testing

To test the model implementation:

1. Run the app and navigate through the normal flow
2. Capture or select an image
3. Verify that predictions appear in the output screen
4. Check the console for any error messages

## Future Improvements

1. Add caching for processed images
2. Implement model accuracy metrics
3. Add fallback mechanisms for failed predictions
4. Optimize image preprocessing for better performance