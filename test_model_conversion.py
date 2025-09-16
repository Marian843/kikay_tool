#!/usr/bin/env python3
"""
Test script to verify model conversion will work properly
"""

import tensorflow as tf
import os

def test_model_loading(model_path):
    """Test if a model can be loaded successfully"""
    try:
        print(f"Testing model: {model_path}")
        if not os.path.exists(model_path):
            print(f"  ERROR: Model file not found at {model_path}")
            return False
            
        # Try to load the model
        model = tf.keras.models.load_model(model_path)
        print(f"  SUCCESS: Model loaded successfully")
        print(f"  Model input shape: {model.input_shape}")
        print(f"  Model output shape: {model.output_shape}")
        print(f"  Number of layers: {len(model.layers)}")
        return True
    except Exception as e:
        print(f"  ERROR: Failed to load model - {str(e)}")
        return False

def test_tflite_conversion(model_path):
    """Test if a model can be converted to TFLite"""
    try:
        print(f"Testing TFLite conversion for: {model_path}")
        if not os.path.exists(model_path):
            print(f"  ERROR: Model file not found at {model_path}")
            return False
            
        # Load the model
        model = tf.keras.models.load_model(model_path)
        
        # Convert to TFLite
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_model = converter.convert()
        
        # Save to temporary file
        temp_path = model_path.replace('.h5', '_test.tflite')
        with open(temp_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"  SUCCESS: Model converted to TFLite")
        print(f"  TFLite model saved to: {temp_path}")
        print(f"  TFLite model size: {len(tflite_model)} bytes")
        
        # Clean up temporary file
        os.remove(temp_path)
        return True
    except Exception as e:
        print(f"  ERROR: Failed to convert model - {str(e)}")
        return False

def main():
    print("Model Conversion Test Script")
    print("=" * 40)
    
    # Define model paths
    skintone_model = "models/mobilenet_skintone_final.h5"
    undertone_model = "models/mobilenet_undertone_final.h5"
    
    # Test model loading
    print("\n1. Testing Model Loading:")
    skintone_load_success = test_model_loading(skintone_model)
    undertone_load_success = test_model_loading(undertone_model)
    
    # Test TFLite conversion
    print("\n2. Testing TFLite Conversion:")
    skintone_convert_success = test_tflite_conversion(skintone_model)
    undertone_convert_success = test_tflite_conversion(undertone_model)
    
    # Summary
    print("\n3. Summary:")
    print(f"  Skintone model loading: {'PASS' if skintone_load_success else 'FAIL'}")
    print(f"  Undertone model loading: {'PASS' if undertone_load_success else 'FAIL'}")
    print(f"  Skintone TFLite conversion: {'PASS' if skintone_convert_success else 'FAIL'}")
    print(f"  Undertone TFLite conversion: {'PASS' if undertone_convert_success else 'FAIL'}")
    
    overall_success = all([
        skintone_load_success, 
        undertone_load_success, 
        skintone_convert_success, 
        undertone_convert_success
    ])
    
    print(f"\nOverall result: {'ALL TESTS PASSED' if overall_success else 'SOME TESTS FAILED'}")
    
    if not overall_success:
        print("\nRecommendation:")
        print("If tests failed, try using Google Colab or Docker for conversion")
        print("as described in the TFLITE_CONVERSION_GUIDE.md")

if __name__ == "__main__":
    main()