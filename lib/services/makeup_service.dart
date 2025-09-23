import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/makeup_product.dart';

class MakeupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names based on CSV files
  static const String baseCollection = 'base_makeup';
  static const String blushCollection = 'blush_makeup';
  static const String eyeCollection = 'eye_makeup';
  static const String lipCollection = 'lip_makeup';

  // Map preference keys to collection names and makeup types
  static final Map<String, Map<String, String>> preferenceMappings = {
    'foundation': {
      'collection': baseCollection,
      'type': 'foundation',
      'displayName': 'Foundation',
    },
    'concealer': {
      'collection': baseCollection,
      'type': 'concealer',
      'displayName': 'Concealer',
    },
    'powder': {
      'collection': baseCollection,
      'type': 'powder',
      'displayName': 'Powder',
    },
    'bbCream': {
      'collection': baseCollection,
      'type': 'bb cream',
      'displayName': 'BB Cream',
    },
    'blush': {
      'collection': blushCollection,
      'type': 'blush',
      'displayName': 'Blush',
    },
    'highlighter': {
      'collection': blushCollection,
      'type': 'highlighter',
      'displayName': 'Highlighter',
    },
    'bronzer': {
      'collection': blushCollection,
      'type': 'bronzer',
      'displayName': 'Bronzer',
    },
    'eyeshadow': {
      'collection': eyeCollection,
      'type': 'eyeshadow',
      'displayName': 'Eyeshadow',
    },
    'eyeliner': {
      'collection': eyeCollection,
      'type': 'eyeliner',
      'displayName': 'Eyeliner',
    },
    'mascara': {
      'collection': eyeCollection,
      'type': 'mascara',
      'displayName': 'Mascara',
    },
    'lipstick': {
      'collection': lipCollection,
      'type': 'lipstick',
      'displayName': 'Lipstick',
    },
    'lipTint': {
      'collection': lipCollection,
      'type': 'lip tint',
      'displayName': 'Lip Tint',
    },
    'lipOil': {
      'collection': lipCollection,
      'type': 'lip oil',
      'displayName': 'Lip Oil',
    },
    'lipGloss': {
      'collection': lipCollection,
      'type': 'lip gloss',
      'displayName': 'Lip Gloss',
    },
  };

  // Fetch makeup products based on preferences, skin tone, and undertone
  Future<Map<String, List<MakeupProduct>>> getRecommendedProducts({
    required Map<String, bool> preferences,
    required String skinTone,
    required String undertone,
    int limit = 5,
  }) async {
    try {
      Map<String, List<MakeupProduct>> recommendations = {};

      // Count actual selected preferences
      final selectedPrefs = preferences.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();

      // Process each selected preference
      for (String prefKey in preferences.keys) {
        if (preferences[prefKey] == true) {
          final mapping = preferenceMappings[prefKey];
          if (mapping != null) {
            final products = await _fetchProductsForType(
              collectionName: mapping['collection']!,
              makeupType: mapping['type']!,
              skinTone: skinTone,
              undertone: undertone,
              limit: limit,
            );

            if (products.isNotEmpty) {
              recommendations[mapping['displayName']!] = products;
            }
          }
        }
      }

      return recommendations;
    } catch (e) {
      return {};
    }
  }

  // Fetch products from a specific collection
  Future<List<MakeupProduct>> _fetchProductsForType({
    required String collectionName,
    required String makeupType,
    required String skinTone,
    required String undertone,
    int limit = 5,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      // Build query based on makeup type and matching criteria
      bool isBaseProduct = [
        'foundation',
        'concealer',
        'base',
        'skin tint',
        'bb cream',
        'powder'
      ].any((type) => makeupType.toLowerCase().contains(type));

      // Try exact match first, then fallback to more flexible matching
      try {
        if (isBaseProduct) {
          // For base products, match both skin tone and undertone
          query = query
              .where('Skintone', isEqualTo: skinTone)
              .where('Undertone', isEqualTo: undertone);
        } else {
          // For other products (eye, lip, blush), match undertone only
          query = query.where('Undertone', isEqualTo: undertone);
        }

        // Filter by makeup type if specified
        if (makeupType != 'all') {
          query = query.where('Makeup_Type', isEqualTo: makeupType);
        }
      } catch (e) {
        // Fallback: get all products from the collection and filter in memory
        final allProducts = await _getAllProductsFromCollection(collectionName);
        return _filterProductsInMemory(
            allProducts, makeupType, skinTone, undertone, isBaseProduct, limit);
      }

      // Limit results
      query = query.limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => MakeupProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get all products from a collection
  Future<List<MakeupProduct>> getAllProducts(String collectionName) async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs
          .map((doc) => MakeupProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Search products by brand or product name
  Future<List<MakeupProduct>> searchProducts({
    String? brand,
    String? productName,
    String? collectionName,
  }) async {
    try {
      Query query = _firestore.collection(collectionName ?? baseCollection);

      if (brand != null) {
        query = query.where('Brand', isEqualTo: brand);
      }

      if (productName != null) {
        query = query.where('Product_Name', isEqualTo: productName);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => MakeupProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Helper method for fallback filtering
  Future<List<MakeupProduct>> _getAllProductsFromCollection(
      String collectionName) async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs
          .map((doc) => MakeupProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Filter products in memory as fallback
  List<MakeupProduct> _filterProductsInMemory(
    List<MakeupProduct> products,
    String makeupType,
    String skinTone,
    String undertone,
    bool isBaseProduct,
    int limit,
  ) {
    try {
      var filtered = products.where((product) {
        // More flexible type matching
        bool typeMatch = product.makeupType
                .toLowerCase()
                .contains(makeupType.toLowerCase()) ||
            makeupType.toLowerCase().contains(product.makeupType.toLowerCase());

        // Handle undertone variations (e.g., "Warm, Neutral" or "Neutral, Cool")
        bool undertoneMatch = product.undertone
                .toLowerCase()
                .contains(undertone.toLowerCase()) ||
            undertone.toLowerCase().contains(product.undertone.toLowerCase());

        if (isBaseProduct) {
          // Handle skin tone variations - only check skin tone for base products
          bool skinToneMatch = product.skinTone != null &&
              product.skinTone!.toLowerCase().contains(skinTone.toLowerCase());
          return typeMatch && undertoneMatch && skinToneMatch;
        } else {
          // For non-base products (eye, lip, blush), only match type and undertone
          return typeMatch && undertoneMatch;
        }
      }).toList();

      return filtered.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  // Helper method to validate and fix image URLs
  String? _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Handle Google Drive URLs
    if (url.contains('drive.google.com')) {
      // Convert Google Drive sharing URLs to direct image URLs
      final driveIdMatch = RegExp(r'/d/([a-zA-Z0-9-_]+)').firstMatch(url);
      if (driveIdMatch != null) {
        final fileId = driveIdMatch.group(1);
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }

    return url;
  }

  // Get collections for different makeup types
  Future<List<String>> getAvailableCollections() async {
    return [baseCollection, blushCollection, eyeCollection, lipCollection];
  }
}
