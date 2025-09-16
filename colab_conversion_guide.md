# Converting Models to TensorFlow Lite using Google Colab

## Step-by-Step Guide

### Step 1: Access Google Colab
1. Open your web browser and go to https://colab.research.google.com/
2. Sign in with your Google account if prompted
3. Click on "New Notebook" to create a new Colab notebook

### Step 2: Upload Model Files
1. In the Colab notebook, click on the folder icon in the left sidebar
2. Click the "Upload" button (folder with up arrow)
3. Select both model files from your local `models` directory:
   - `mobilenet_skintone_final.h5`
   - `mobilenet_undertone_final.h5`

### Step 3: Run Conversion Code
1. In the first cell of your notebook, paste the following code:

```python
import tensorflow as tf
import os

# Confirm TensorFlow version
print(f"TensorFlow version: {tf.__version__}")

# List files to verify upload
print("Files in current directory:")
for file in os.listdir('.'):
    print(f"  {file}")

# Convert skintone model
print("\nConverting skintone model...")
try:
    skintone_model = tf.keras.models.load_model('mobilenet_skintone_final.h5')
    skintone_converter = tf.lite.TFLiteConverter.from_keras_model(skintone_model)
    skintone_converter.optimizations = [tf.lite.Optimize.DEFAULT]
    skintone_tflite_model = skintone_converter.convert()
    
    with open('skintone_model.tflite', 'wb') as f:
        f.write(skintone_tflite_model)
    print("Skintone model converted successfully!")
except Exception as e:
    print(f"Error converting skintone model: {str(e)}")

# Convert undertone model
print("\nConverting undertone model...")
try:
    undertone_model = tf.keras.models.load_model('mobilenet_undertone_final.h5')
    undertone_converter = tf.lite.TFLiteConverter.from_keras_model(undertone_model)
    undertone_converter.optimizations = [tf.lite.Optimize.DEFAULT]
    undertone_tflite_model = undertone_converter.convert()
    
    with open('undertone_model.tflite', 'wb') as f:
        f.write(undertone_tflite_model)
    print("Undertone model converted successfully!")
except Exception as e:
    print(f"Error converting undertone model: {str(e)}")

# Verify the TFLite models were created
print("\nFiles after conversion:")
for file in os.listdir('.'):
    if 'tflite' in file:
        size = os.path.getsize(file) / (1024 * 1024)  # Size in MB
        print(f"  {file} ({size:.2f} MB)")
```

2. Click the "Play" button or press Ctrl+Enter to run the cell

### Step 4: Download Converted Models
1. After the conversion completes successfully, click on the folder icon again
2. You should see two new files:
   - `skintone_model.tflite`
   - `undertone_model.tflite`
3. Right-click on each file and select "Download" to save them to your computer

### Step 5: Use in Flutter App
1. Create an `assets/models` directory in your Flutter project
2. Move the downloaded TFLite models to this directory
3. Update your `pubspec.yaml` to include the models:

```yaml
flutter:
  assets:
    - assets/models/skintone_model.tflite
    - assets/models/undertone_model.tflite
```

4. Add the TensorFlow Lite Flutter package to your `pubspec.yaml`:

```yaml
dependencies:
  tflite_flutter: ^0.10.0
```

5. Run `flutter pub get` to install the dependencies

## Troubleshooting

### If you get memory errors:
Try adding this line before loading each model:
```python
import tensorflow as tf
tf.config.experimental.set_memory_growth(tf.config.list_physical_devices('GPU')[0], True)
```

### If you get model loading errors:
The models might require specific dependencies. Try:
```python
skintone_model = tf.keras.models.load_model('mobilenet_skintone_final.h5', compile=False)
```

### Need help?
If you encounter any issues, please share the error message for specific assistance.