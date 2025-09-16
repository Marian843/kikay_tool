#!/usr/bin/env python3
"""
Script to convert H5 models to TensorFlow Lite format using Docker
"""
import tensorflow as tf
import os

def convert_model(h5_path, tflite_path):
    """Convert an H5 model to TensorFlow Lite format"""
    print(f"Converting {h5_path} to {tflite_path}...")
    
    try:
        # Load the H5 model
        model = tf.keras.models.load_model(h5_path)
        print(f"Model loaded successfully")
        
        # Convert the model
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        
        # Convert and save
        tflite_model = converter.convert()
        
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        # Get file sizes
        h5_size = os.path.getsize(h5_path) / (1024 * 1024)
        tflite_size = os.path.getsize(tflite_path) / (1024 * 1024)
        
        print(f"Successfully converted {h5_path} ({h5_size:.2f} MB) to {tflite_path} ({tflite_size:.2f} MB)")
        return True
        
    except Exception as e:
        print(f"Error converting {h5_path}: {str(e)}")
        return False

def main():
    print(f"TensorFlow version: {tf.__version__}")
    print("Starting model conversion...")
    
    # Create output directory
    os.makedirs("tflite_models", exist_ok=True)
    
    # Models to convert
    models_to_convert = [
        ("models/mobilenet_skintone_final.h5", "tflite_models/skintone_model.tflite"),
        ("models/mobilenet_undertone_final.h5", "tflite_models/undertone_model.tflite")
    ]
    
    # Convert each model
    success_count = 0
    for h5_path, tflite_path in models_to_convert:
        if os.path.exists(h5_path):
            if convert_model(h5_path, tflite_path):
                success_count += 1
        else:
            print(f"Model file not found: {h5_path}")
    
    print(f"\nConversion completed! {success_count}/{len(models_to_convert)} models converted successfully.")
    
    # List the TFLite models
    if os.path.exists("tflite_models"):
        print("\nTFLite models created:")
        for file in os.listdir("tflite_models"):
            size = os.path.getsize(f"tflite_models/{file}") / (1024 * 1024)
            print(f"  {file} ({size:.2f} MB)")

if __name__ == "__main__":
    main()