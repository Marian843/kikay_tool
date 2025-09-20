import 'dart:io';
import 'package:image/image.dart' as img;
import 'lib/services/model_service.dart';

void main() {
  print('=== RGB UNDERTONE ANALYSIS TEST ===');

  final modelService = ModelService();

  // Test cases with different RGB values representing different undertones
  final testCases = [
    {
      'name': 'Warm Undertone (High Red)',
      'rgb': {'red': 200.0, 'green': 180.0, 'blue': 150.0},
      'expected': 'Warm'
    },
    {
      'name': 'Cool Undertone (High Blue)',
      'rgb': {'red': 150.0, 'green': 160.0, 'blue': 200.0},
      'expected': 'Cool'
    },
    {
      'name': 'Neutral Undertone (Balanced)',
      'rgb': {'red': 180.0, 'green': 180.0, 'blue': 180.0},
      'expected': 'Neutral'
    },
    {
      'name': 'Warm Undertone (Yellowish)',
      'rgb': {'red': 190.0, 'green': 185.0, 'blue': 160.0},
      'expected': 'Warm'
    },
    {
      'name': 'Cool Undertone (Pinkish)',
      'rgb': {'red': 170.0, 'green': 150.0, 'blue': 180.0},
      'expected': 'Cool'
    },
  ];

  print('\nTesting RGB-based undertone determination...\n');

  for (final testCase in testCases) {
    print('--- Test Case: ${testCase['name']} ---');
    print('Input RGB: ${testCase['rgb']}');
    print('Expected Undertone: ${testCase['expected']}');

    final result = modelService.determineUndertoneFromRGB(
        Map<String, double>.from(testCase['rgb'] as Map));

    print('Actual Undertone: $result');

    final isCorrect = result == testCase['expected'];
    print('Test Result: ${isCorrect ? '✅ PASS' : '❌ FAIL'}');
    print('');
  }

  print('=== TEST SUMMARY ===');
  print('RGB undertone analysis logic has been tested with various scenarios.');
  print(
      'The implementation compares relative levels of red/blue/green to determine:');
  print(
      '- Warm undertones → more yellow/red (higher red and green compared to blue)');
  print(
      '- Cool undertones → more blue/pink (higher blue compared to red and green)');
  print('- Neutral → balanced RGB values');
  print('');
  print('Key ratios analyzed:');
  print('- Red/Green ratio: Should be close to 1.0 for balanced warm/neutral');
  print('- Red/Blue ratio: > 1.1 indicates warm, < 0.9 indicates cool');
  print('- Green/Blue ratio: < 0.9 indicates cool undertone');
  print('');
  print('The logging output shows detailed analysis of each test case.');
}
