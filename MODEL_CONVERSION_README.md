# Model Conversion to TensorFlow Lite

This document provides detailed instructions for converting the skin tone and undertone detection models from H5 format to TensorFlow Lite (TFLite) format.

## Models to Convert

1. `models/mobilenet_skintone_final.h5` - Skin tone detection model
2. `models/mobilenet_undertone_final.h5` - Undertone detection model

## Why Convert to TFLite?

TensorFlow Lite is TensorFlow's lightweight solution for mobile and embedded device deployment. It enables on-device machine learning inference with low latency and small binary size, making it perfect for mobile apps like Kikay.

## Conversion Methods

### Method 1: Google Colab (Recommended for Windows users)

This is the easiest method for Windows users due to path length limitations.

#### Steps:
1. Go to [Google Colab](https://colab.research.google.com/)
2. Create a new notebook
3. Upload the H5 model files using the file browser
4. Run the conversion code (provided in the batch script)
5. Download the converted TFLite models

#### Advantages:
- No local installation required
- Works around Windows path limitations
- Access to powerful GPUs if needed

#### Disadvantages:
- Requires internet connection
- Files must be uploaded and downloaded

### Method 2: Docker (Recommended for local conversion)

This method uses Docker to create a container with TensorFlow installed.

#### Prerequisites:
- Docker Desktop installed on your system

#### Steps:
1. Make sure Docker Desktop is running
2. Open PowerShell in the project directory
3. Build the Docker image:
   ```
   docker build -t tflite-converter .
   ```
4. Run the conversion:
   ```
   docker run -v ${PWD}:/app tflite-converter
   ```
5. The TFLite models will be created in the models directory

#### Advantages:
- Runs locally without internet (after initial setup)
- Consistent environment
- No path length issues

#### Disadvantages:
- Requires Docker installation
- Slightly more complex setup

### Method 3: Linux/WSL

If you have access to a Linux environment or WSL, you can install TensorFlow directly.

#### Steps:
1. Install Python 3 if not already installed
2. Install TensorFlow:
   ```
   pip install tensorflow
   ```
3. Run the conversion script:
   ```
   python convert_models.py
   ```

## Conversion Process Details

The conversion process uses TensorFlow's built-in converter with default optimizations:

```python
# Load the Keras model
model = tf.keras.models.load_model('model_file.h5')

# Create a TensorFlow Lite converter
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# Apply default optimizations
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# Convert the model
tflite_model = converter.convert()
```

The `tf.lite.Optimize.DEFAULT` setting applies a set of optimizations that can reduce model size and improve performance with minimal impact on accuracy.

## Next Steps After Conversion

After successfully converting the models:

1. Move the TFLite models to your Flutter project's assets directory:
   ```
   assets/
   └── models/
       ├── skintone_model.tflite
       └── undertone_model.tflite
   ```

2. Update your `pubspec.yaml` to include the models:
   ```yaml
   flutter:
     assets:
       - assets/models/skintone_model.tflite
       - assets/models/undertone_model.tflite
   ```

3. Integrate the models into your Flutter app using the `tflite_flutter` package

## Troubleshooting

### Common Issues:

1. **Model loading errors**: Ensure the H5 files are not corrupted
2. **Memory issues**: The conversion process can be memory-intensive
3. **Permission errors**: Make sure Docker has access to your file system

### Solutions:

1. **Verify model integrity**:
   ```python
   import tensorflow as tf
   model = tf.keras.models.load_model('model_file.h5')
   print(model.summary())
   ```

2. **Increase Docker memory allocation** in Docker Desktop settings

3. **Check file permissions** on your model files

## Support

If you encounter any issues with the conversion process, please check:
1. That the H5 files exist and are not corrupted
2. That you have sufficient disk space and memory
3. That Docker is properly configured (if using Docker method)
4. That you have a stable internet connection (if using Google Colab)