import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

class CsvFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadCsvToFirestore(
      String assetPath, String collectionName) async {
    try {
      // Load CSV file from assets
      String csvData = await rootBundle.loadString(assetPath);

      // Parse CSV data
      List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

      // Get headers (first row)
      List<dynamic> headers = csvTable[0];

      // Get collection reference
      CollectionReference collection = _firestore.collection(collectionName);

      // Process each row (skip header row)
      for (int i = 1; i < csvTable.length; i++) {
        Map<String, dynamic> documentData = {};

        // Map each value to its corresponding header
        for (int j = 0; j < headers.length; j++) {
          if (j < csvTable[i].length) {
            String header = headers[j].toString();
            dynamic value = csvTable[i][j];

            // Skip empty headers or values
            if (header.isNotEmpty && value.toString().isNotEmpty) {
              documentData[header] = value;
            }
          }
        }

        // Add document to Firestore
        if (documentData.isNotEmpty) {
          await collection.add(documentData);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadAllMakeupData() async {
    try {
      // Upload all CSV files
      // await uploadCsvToFirestore('assets/Base.csv', 'base_makeup');
      await uploadCsvToFirestore('assets/Blush.csv', 'blush_makeup');
      // await uploadCsvToFirestore('assets/Eye.csv', 'eye_makeup');
      // await uploadCsvToFirestore('assets/Lip.csv', 'lip_makeup');
    } catch (e) {
      rethrow;
    }
  }
}
