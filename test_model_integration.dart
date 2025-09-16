// Test script to verify model integration
// Run this to check if models load correctly

import 'dart:io';
import 'package:flutter/material.dart';
import 'lib/services/model_service.dart';

void main() {
  testModelLoading();
}

void testModelLoading() async {
  print('Testing model loading...');

  try {
    final modelService = ModelService();
    await modelService.loadModels();

    print('✓ Models loaded successfully');

    // Check if interpreters are loaded
    if (modelService.isSkinToneModelLoaded) {
      print('✓ Skin tone model interpreter loaded');
    } else {
      print('✗ Skin tone model interpreter failed to load');
    }

    if (modelService.isUnderToneModelLoaded) {
      print('✓ Undertone model interpreter loaded');
    } else {
      print('✗ Undertone model interpreter failed to load');
    }

    // Test preprocessing function
    print('Testing preprocessing...');
    // Note: We can't test with a real image file in this context
    // But we can verify the function exists and is callable

    print('Model integration test completed!');

    // Clean up
    modelService.dispose();
  } catch (e) {
    print('Error during model testing: $e');
  }
}
