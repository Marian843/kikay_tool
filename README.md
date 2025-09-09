Kikay: A Facial Image-Based CNN and CIELAB System for Skin Tone and Undertone Detection

Kikay is an AI-powered system that leverages Convolutional Neural Networks (CNN) and the CIELAB color space to analyze facial images and determine skin tone and undertone. It aims to assist users in finding makeup, skincare, or fashion products that suit their natural complexion.

Features
- Upload and analyze facial images
- Detect skin tone using CIELAB color space
- Classify undertone as warm, cool, or neutral using a trained CNN
- Recommend suitable shades for makeup and cosmetics
- Real-time prediction with a user-friendly interface

How It Works
1. Image Preprocessing
   - Facial region is detected and cropped using OpenCV.

2. Skin Tone Detection
   - Dominant skin pixels are converted to CIELAB values to classify tone.

3. Undertone Classification 
   - A CNN model processes the face crop and predicts undertone (cool, warm, or neutral).

4. Results Displayed
   - Skin tone level (e.g., light, medium, dark)
   - Undertone (e.g., cool)
   - Suggested compatible shades

Technologies Used
- Figma
- Flutter (for frontend UI)
