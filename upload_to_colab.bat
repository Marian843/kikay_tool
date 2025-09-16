@echo off
echo ====================================================
echo Google Colab Upload Helper
echo ====================================================
echo.
echo Instructions:
echo 1. Go to https://colab.research.google.com/
echo 2. Create a new notebook
echo 3. Click on the folder icon in the left sidebar
echo 4. Click the upload button
echo 5. Select the following files:
echo    - models/mobilenet_skintone_final.h5
echo    - models/mobilenet_undertone_final.h5
echo.
echo After uploading, run the following code in a cell:
echo ====================================================
echo.
echo import tensorflow as tf
echo.
echo # Convert skintone model
echo model = tf.keras.models.load_model('mobilenet_skintone_final.h5')
echo converter = tf.lite.TFLiteConverter.from_keras_model(model)
echo converter.optimizations = [tf.lite.Optimize.DEFAULT]
echo tflite_model = converter.convert()
echo.
echo with open('skintone_model.tflite', 'wb') as f:
echo     f.write(tflite_model)
echo.
echo # Convert undertone model
echo model = tf.keras.models.load_model('mobilenet_undertone_final.h5')
echo converter = tf.lite.TFLiteConverter.from_keras_model(model)
echo converter.optimizations = [tf.lite.Optimize.DEFAULT]
echo tflite_model = converter.convert()
echo.
echo with open('undertone_model.tflite', 'wb') as f:
echo     f.write(tflite_model)
echo.
echo # Download the models
echo from google.colab import files
echo files.download('skintone_model.tflite')
echo files.download('undertone_model.tflite')
echo.
echo ====================================================
echo Press any key to continue...
pause >nul