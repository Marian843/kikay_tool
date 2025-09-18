# Makeup Recommendations Feature - Implementation Guide

## Overview
This feature integrates with Firestore to provide personalized makeup recommendations based on:
- **Skin tone** (from AI model analysis)
- **Undertone** (from AI model analysis) 
- **User preferences** (selected makeup products)

## Architecture

### 1. Data Models
- **MakeupProduct** (`lib/models/makeup_product.dart`): Model class representing makeup products from CSV/Firestore
- **UserPreferences** (`lib/screens/preferences.dart`): User-selected makeup preferences

### 2. Services
- **MakeupService** (`lib/services/makeup_service.dart`): Fetches recommendations from Firestore
- **CsvFirestoreService** (`lib/services/csv_firestore_service.dart`): Uploads CSV data to Firestore
- **ModelService** (`lib/services/model_service.dart`): AI model for skin tone/undertone detection

### 3. Screens
- **PreferencesPage** (`lib/screens/preferences.dart`): User selects desired makeup products
- **ImageResultPage** (`lib/screens/output.dart`): Displays AI analysis + makeup recommendations

## Data Structure

### CSV Files to Firestore Mapping
| CSV File | Firestore Collection | Product Types |
|----------|---------------------|---------------|
| Base.csv | base_makeup | Foundation, Concealer, Powder, BB Cream |
| Blush.csv | blush_makeup | Blush, Highlighter, Bronzer |
| Eye.csv | eye_makeup | Eyeshadow, Eyeliner, Mascara |
| Lip.csv | lip_collection | Lipstick, Lip Tint, Lip Oil, Lip Gloss |

### Matching Logic
- **Base products** (Foundation, Concealer): Match both **skin tone + undertone**
- **Other products** (Eye, Lip, Blush): Match **undertone only**

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub add csv
flutter pub add cloud_firestore
flutter pub add firebase_core
```

### 2. Upload CSV Data to Firestore

#### Option A: Manual Upload via Code
Create a temporary upload screen or use this code in main.dart:

```dart
import 'package:kikay/services/csv_firestore_service.dart';

// Call this function once to upload CSV data
final csvService = CsvFirestoreService();
await csvService.uploadAllMakeupData();
```

#### Option B: Firebase Console Upload
1. Go to Firebase Console → Firestore Database
2. Create collections: `base_makeup`, `blush_makeup`, `eye_makeup`, `lip_makeup`
3. Import CSV data manually

### 3. Firestore Security Rules
Add these rules for secure access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to makeup collections
    match /base_makeup/{document} {
      allow read: if true;
    }
    match /blush_makeup/{document} {
      allow read: if true;
    }
    match /eye_makeup/{document} {
      allow read: if true;
    }
    match /lip_makeup/{document} {
      allow read: if true;
    }
  }
}
```

## Usage Flow

### 1. User Journey
```
Camera Screen → Preferences Page → Result Page
```

### 2. Preferences Selection
Users select desired makeup products:
- **Base**: Foundation, Concealer, Powder, BB Cream
- **Cheeks**: Blush, Highlighter, Bronzer  
- **Eyes**: Eyeshadow, Eyeliner, Mascara
- **Lips**: Lipstick, Lip Tint, Lip Oil, Lip Gloss

### 3. Recommendation Display
- Shows 3 products per selected category
- Displays brand, shade name, and product image
- Filters based on detected skin tone/undertone

## API Reference

### MakeupService Methods

#### `getRecommendedProducts()`
```dart
final recommendations = await makeupService.getRecommendedProducts(
  preferences: {
    'foundation': true,
    'blush': true,
    'lipstick': true,
  },
  skinTone: 'Fair',
  undertone: 'Warm',
  limit: 3,
);
```

#### `searchProducts()`
```dart
// Search by brand
final products = await makeupService.searchProducts(
  brand: 'Colourette',
  collectionName: 'base_makeup'
);
```

## Testing

### Test Data Upload
```dart
// Test CSV upload
final csvService = CsvFirestoreService();
try {
  await csvService.uploadCsvToFirestore('assets/Base.csv', 'base_makeup');
  print('Base makeup uploaded successfully');
} catch (e) {
  print('Upload failed: $e');
}
```

### Test Recommendations
```dart
// Test recommendation fetching
final makeupService = MakeupService();
final recommendations = await makeupService.getRecommendedProducts(
  preferences: {'foundation': true, 'blush': true},
  skinTone: 'Fair',
  undertone: 'Warm',
);
print('Found ${recommendations.length} categories');
```

## Troubleshooting

### Common Issues

1. **No recommendations showing**
   - Check if CSV data is uploaded to Firestore
   - Verify Firestore security rules allow reads
   - Check console logs for errors

2. **Images not loading**
   - Ensure image URLs in CSV are publicly accessible
   - Check if image URLs are properly formatted

3. **Wrong recommendations**
   - Verify skin tone/undertone detection accuracy
   - Check CSV data format matches expected structure

### Debug Steps
1. Check Firestore collections exist with data
2. Verify network connectivity
3. Check console logs for API errors
4. Test with different skin tone/undertone combinations

## CSV Data Format

### Required Columns
- `Makeup_Type`: Product category (e.g., 'foundation', 'blush')
- `Brand`: Brand name
- `Product_Name`: Product name
- `Shade_Name`: Shade/variant name
- `Undertone`: 'Warm', 'Cool', or 'Neutral'
- `Skintone`: 'Fair', 'Light', 'Medium', etc. (for base products)

### Optional Columns
- `Shade_Description`: Additional shade details
- `Finish`: 'Matte', 'Shimmer', 'Glossy', etc.
- `Image`: Direct image URL
- `Image Link`: Google Drive or external image link

## Performance Optimization

- **Limit results**: Use `limit` parameter to control product count
- **Caching**: Consider implementing local caching for frequent queries
- **Pagination**: Add pagination for large product catalogs
- **Image optimization**: Use optimized image URLs for faster loading

## Future Enhancements

- [ ] Add favorite/save products feature
- [ ] Implement user rating system
- [ ] Add price comparison functionality
- [ ] Include availability check (online stores)
- [ ] Add virtual try-on integration
- [ ] Support for more makeup brands
- [ ] Advanced filtering (price range, ingredients, etc.)
