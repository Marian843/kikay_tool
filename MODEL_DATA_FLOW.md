# Model Data Flow Documentation

This document explains how data flows through the Kikay app for skin tone and undertone detection using TensorFlow Lite models.

## Overview

The implementation follows this data flow:
1. Image capture/selection
2. Navigation through app screens
3. Model prediction
4. Display of results

## Component Interaction

### 1. Model Service (`lib/services/model_service.dart`)

**Responsibilities:**
- Load TFLite models from assets
- Preprocess images for model input
- Run predictions on skin tone and undertone models
- Convert model outputs to readable labels
- Manage resources (interpreters)

**Public Interface:**
```dart
class ModelService {
  Future<void> loadModels() // Load both models at startup
  List<double>? predictSkinTone(File imageFile) // Run skin tone prediction
  List<double>? predictUnderTone(File imageFile) // Run undertone prediction
  String getSkinToneLabel(List<double> prediction) // Convert to label
  String getUnderToneLabel(List<double> prediction) // Convert to label
  void dispose() // Free resources
}
```

### 2. Main Application (`lib/main.dart`)

**Role:** Initialize the ModelService when the app starts

**Implementation:**
```dart
late ModelService modelService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... other initialization
  
  // Initialize model service
  modelService = ModelService();
  await modelService.loadModels();
  
  runApp(const MyApp());
}
```

### 3. Routing (`lib/routes.dart`)

**Role:** Pass the ModelService to screens that need it

**Key Points:**
- ModelService is globally accessible after initialization
- Output screen receives the ModelService through route arguments

### 4. Output Screen (`lib/screens/output.dart`)

**Role:** Display model predictions to the user

**Data Flow:**
1. Receives image path and ModelService through constructor
2. Runs predictions when screen loads (`initState`)
3. Displays results in the UI

**Constructor:**
```dart
const ImageResultPage({
  required this.imagePath,
  required this.skinTone,
  required this.undertone,
  required this.modelService,
});
```

**Prediction Process:**
```dart
Future<void> _analyzeImage() async {
  // Run predictions using the model service
  final skinTonePrediction = widget.modelService.predictSkinTone(File(widget.imagePath));
  final undertonePrediction = widget.modelService.predictUnderTone(File(widget.imagePath));

  if (skinTonePrediction != null) {
    _predictedSkinTone = widget.modelService.getSkinToneLabel(skinTonePrediction);
  }

  if (undertonePrediction != null) {
    _predictedUndertone = widget.modelService.getUnderToneLabel(undertonePrediction);
  }
}
```

## Data Passed Between Components

### 1. Image Path
- **Source:** Camera screen captures image or user selects from gallery
- **Flow:** Passed through navigation as route arguments
- **Format:** String representing file path
- **Example:** `/data/user/0/com.example.kikay/cache/image.jpg`

### 2. Model Service
- **Source:** Initialized in main.dart
- **Flow:** Passed through routes to output screen
- **Usage:** Used to run predictions on images

### 3. Predictions
- **Source:** TFLite model inference
- **Format:** List of probabilities (List<double>)
- **Example:** [0.1, 0.7, 0.2] for 3-class undertone model

### 4. Labels
- **Source:** ModelService converts predictions to labels
- **Format:** Human-readable strings
- **Examples:** 
  - Skin Tone: "Fair", "Light", "Medium", "Olive", "Brown", "Dark"
  - Undertone: "Cool", "Warm", "Neutral"

## Navigation Flow

1. **Camera Screen** (`/camera`)
   - Captures image or allows selection from gallery
   - Navigates to Result Screen with image path

2. **Result Screen** (`/result`)
   - Displays captured/selected image
   - Navigates to Preferences Screen with image path

3. **Preferences Screen** (`/preferences`)
   - Allows user to select makeup preferences
   - Navigates to Output Screen with image path

4. **Output Screen** (`/output`)
   - Receives image path and ModelService
   - Runs predictions on image
   - Displays results to user

## Error Handling

### Model Loading Errors
- Logged to console
- App continues to function (with fallback values)

### Image Processing Errors
- Logged to console
- UI shows error state
- Fallback to default values

### Prediction Errors
- Logged to console
- UI shows loading state or error message
- Fallback to default values

## Performance Considerations

### Model Loading
- Done once at app startup
- Models cached in memory
- Asynchronous loading to avoid blocking UI

### Image Processing
- Runs on background thread
- Resizes images to model input size (224x224)
- Normalizes pixel values to [0, 1] range

### Memory Management
- Interpreters disposed when no longer needed
- ModelService can be reused across predictions
- Images processed one at a time

## Testing Points

### Verify Model Loading
- Check console for "Models loaded successfully" message
- Verify both models load without errors

### Verify Image Processing
- Test with various image formats
- Test with different image sizes
- Verify preprocessing output format

### Verify Predictions
- Test with sample images
- Verify prediction results are reasonable
- Check label conversion accuracy

### Verify UI Integration
- Confirm predictions display correctly
- Test error states
- Verify loading states