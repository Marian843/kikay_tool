# TensorFlow Lite Model Conversion Guide

This guide explains how to convert the skin tone and undertone detection H5 models to TensorFlow Lite format.

## Prerequisites

You'll need one of these environments:
1. Google Colab (recommended for beginners)
2. Docker Desktop (for local conversion)
3. Linux environment/WSL (if available)

## Method 1: Google Colab (Recommended)

1. Go to [Google Colab](https://colab.research.google.com/)
2. Create a new notebook
3. Upload the following files:
   - `models/mobilenet_skintone_final.h5`
   - `models/mobilenet_undertone_final.h5`
4. Run this conversion code in a cell:

```python
import tensorflow as tf

# Convert skintone model
print("Converting skintone model...")
model = tf.keras.models.load_model('mobilenet_skintone_final.h5')
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open('skintone_model.tflite', 'wb') as f:
    f.write(tflite_model)
print("Skintone model converted successfully!")

# Convert undertone model
print("Converting undertone model...")
model = tf.keras.models.load_model('mobilenet_undertone_final.h5')
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open('undertone_model.tflite', 'wb') as f:
    f.write(tflite_model)
print("Undertone model converted successfully!")

# Download the TFLite models
from google.colab import files
files.download('skintone_model.tflite')
files.download('undertone_model.tflite')
```

## Method 2: Docker Approach

1. Install Docker Desktop if not already installed
2. Create a Dockerfile in your project directory:

```dockerfile
FROM tensorflow/tensorflow:2.13.0

WORKDIR /app
COPY . .

CMD ["python", "convert_models.py"]
```

3. Create a conversion script `convert_models.py`:

```python
import tensorflow as tf
import os

def convert_model(h5_path, tflite_path):
    print(f"Converting {h5_path} to {tflite_path}...")
    model = tf.keras.models.load_model(h5_path)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    print(f"Successfully converted {h5_path} to {tflite_path}")

if __name__ == "__main__":
    # Convert skintone model
    convert_model(
        'models/mobilenet_skintone_final.h5',
        'models/skintone_model.tflite'
    )
    
    # Convert undertone model
    convert_model(
        'models/mobilenet_undertone_final.h5',
        'models/undertone_model.tflite'
    )
    
    print("All models converted successfully!")
```

4. Build and run the Docker container:
```bash
docker build -t tflite-converter .
docker run -v ${PWD}:/app tflite-converter
```

## Method 3: Linux/WSL (Alternative)

If you have access to a Linux environment or WSL:

1. Install TensorFlow:
```bash
pip install tensorflow
```

2. Run the conversion script:
```python
import tensorflow as tf

# Convert skintone model
model = tf.keras.models.load_model('models/mobilenet_skintone_final.h5')
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open('models/skintone_model.tflite', 'wb') as f:
    f.write(tflite_model)

# Convert undertone model
model = tf.keras.models.load_model('models/mobilenet_undertone_final.h5')
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open('models/undertone_model.tflite', 'wb') as f:
    f.write(tflite_model)
```

## Next Steps

After converting the models:
1. Place the TFLite models in your Flutter project's `assets/models/` directory
2. Add the models to your `pubspec.yaml` file
3. Use the `tflite_flutter` package to integrate the models into your app