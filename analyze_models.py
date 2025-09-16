#!/usr/bin/env python3
"""
Script to prepare model files for TensorFlow Lite conversion
This script creates a simple report about the H5 models and prepares them for conversion
"""

import os
import h5py
import json
import numpy as np

def analyze_h5_model(h5_path):
    """
    Analyze an H5 model file and extract information about it
    """
    print(f"Analyzing {h5_path}")
    
    if not os.path.exists(h5_path):
        print(f"File {h5_path} does not exist")
        return None
    
    try:
        with h5py.File(h5_path, 'r') as h5_file:
            info = {
                'file_name': os.path.basename(h5_path),
                'file_size_mb': round(os.path.getsize(h5_path) / (1024 * 1024), 2),
                'groups': [],
                'datasets': []
            }
            
            def visit_func(name, obj):
                if isinstance(obj, h5py.Group):
                    # Convert attributes to serializable format
                    attrs = {}
                    for key, value in obj.attrs.items():
                        if isinstance(value, np.ndarray):
                            attrs[key] = value.tolist()
                        else:
                            attrs[key] = str(value)
                    
                    info['groups'].append({
                        'name': name,
                        'attributes': attrs
                    })
                elif isinstance(obj, h5py.Dataset):
                    info['datasets'].append({
                        'name': name,
                        'shape': obj.shape,
                        'dtype': str(obj.dtype)
                    })
            
            h5_file.visititems(visit_func)
            
            print(f"File size: {info['file_size_mb']} MB")
            print(f"Groups found: {len(info['groups'])}")
            print(f"Datasets found: {len(info['datasets'])}")
            
            # Show first few datasets
            print("First 5 datasets:")
            for i, dataset in enumerate(info['datasets'][:5]):
                print(f"  {i+1}. {dataset['name']} - Shape: {dataset['shape']}, Dtype: {dataset['dtype']}")
            
            return info
            
    except Exception as e:
        print(f"Error analyzing model: {str(e)}")
        return None

def create_conversion_instructions():
    """
    Create instructions for converting the models
    """
    instructions = """
    === TensorFlow Lite Conversion Instructions ===
    
    Due to Windows Long Path limitations, we cannot install the full TensorFlow package directly.
    Here's how to convert these H5 models to TensorFlow Lite format:
    
    Option 1: Use Google Colab (Recommended)
    1. Go to https://colab.research.google.com/
    2. Create a new notebook
    3. Upload these H5 files to your Colab environment
    4. Run the following code in a cell:
    
    ```python
    import tensorflow as tf
    
    # Convert skintone model
    model = tf.keras.models.load_model('mobilenet_skintone_final.h5')
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    with open('skintone_model.tflite', 'wb') as f:
        f.write(tflite_model)
    
    # Convert undertone model
    model = tf.keras.models.load_model('mobilenet_undertone_final.h5')
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    with open('undertone_model.tflite', 'wb') as f:
        f.write(tflite_model)
    ```
    
    Option 2: Use a Linux environment
    1. Transfer these H5 files to a Linux machine or WSL
    2. Install TensorFlow: pip install tensorflow
    3. Run the conversion script provided above
    
    Option 3: Use Docker
    1. Install Docker Desktop
    2. Run a TensorFlow container and mount this directory
    3. Perform the conversion inside the container
    """
    
    with open("conversion_instructions.txt", "w") as f:
        f.write(instructions)
    
    print("Conversion instructions saved to conversion_instructions.txt")
    return instructions

def main():
    # Define model paths
    models_dir = "models"
    
    # Models to analyze
    models_to_analyze = [
        "mobilenet_skintone_final.h5",
        "mobilenet_undertone_final.h5"
    ]
    
    # Analyze each model
    model_info = {}
    for model_filename in models_to_analyze:
        h5_path = os.path.join(models_dir, model_filename)
        info = analyze_h5_model(h5_path)
        if info:
            model_info[model_filename] = info
        print()
    
    # Save model information to JSON
    with open("model_info.json", "w") as f:
        json.dump(model_info, f, indent=2, default=str)
    
    print("Model information saved to model_info.json")
    
    # Create conversion instructions
    instructions = create_conversion_instructions()
    print(instructions)

if __name__ == "__main__":
    main()
    print("Analysis completed!")