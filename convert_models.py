import tensorflow as tf
import os

def convert_model(h5_path, tflite_path):
    """
    Convert an H5 model to TensorFlow Lite format
    """
    print(f"Converting {h5_path} to {tflite_path}...")
    
    # Load the Keras model
    model = tf.keras.models.load_model(h5_path)
    
    # Convert the model to TensorFlow Lite format
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    # Save the TFLite model
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Successfully converted {h5_path} to {tflite_path}")
    return tflite_path

if __name__ == "__main__":
    # Create models directory if it doesn't exist
    os.makedirs('models', exist_ok=True)
    
    # Convert skintone model
    skintone_h5 = 'models/mobilenet_skintone_final.h5'
    skintone_tflite = 'models/skintone_model.tflite'
    
    if os.path.exists(skintone_h5):
        convert_model(skintone_h5, skintone_tflite)
    else:
        print(f"Warning: {skintone_h5} not found")
    
    # Convert undertone model
    undertone_h5 = 'models/mobilenet_undertone_final.h5'
    undertone_tflite = 'models/undertone_model.tflite'
    
    if os.path.exists(undertone_h5):
        convert_model(undertone_h5, undertone_tflite)
    else:
        print(f"Warning: {undertone_h5} not found")
    
    print("Model conversion process completed!")