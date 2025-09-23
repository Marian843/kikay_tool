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
      print(
          'Getting recommended products for skinTone: $skinTone, undertone: $undertone');

      // Count actual selected preferences
      final selectedPrefs = preferences.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();
      print('Selected preferences: $selectedPrefs');

      // Process each selected preference
      for (String prefKey in preferences.keys) {
        if (preferences[prefKey] == true) {
          final mapping = preferenceMappings[prefKey];
          if (mapping != null) {
            print('Fetching products for ${mapping['displayName']}...');
            final products = await _fetchProductsForType(
              collectionName: mapping['collection']!,
              makeupType: mapping['type']!,
              skinTone: skinTone,
              undertone: undertone,
              limit: limit,
            );

            print(
                'Found ${products.length} products for ${mapping['displayName']}');

            if (products.isNotEmpty) {
              recommendations[mapping['displayName']!] = products;
            } else {
              print(
                  'No products found for ${mapping['displayName']}, trying fallback...');
              // Try fallback: get any products of this type regardless of skin tone/undertone
              final fallbackProducts = await _getAnyProductsOfType(
                collectionName: mapping['collection']!,
                makeupType: mapping['type']!,
                limit: limit,
              );

              print(
                  'Found ${fallbackProducts.length} fallback products for ${mapping['displayName']}');

              if (fallbackProducts.isNotEmpty) {
                recommendations[mapping['displayName']!] = fallbackProducts;
              }
            }
          }
        }
      }

      print('Final recommendations: ${recommendations.keys}');
      return recommendations;
    } catch (e) {
      print('Error in getRecommendedProducts: $e');
      return {};
    }
  }

  // Get any products of a specific type as a fallback
  Future<List<MakeupProduct>> _getAnyProductsOfType({
    required String collectionName,
    required String makeupType,
    required int limit,
  }) async {
    try {
      print('Getting any products of type $makeupType from $collectionName');
      final allProducts = await _getAllProductsFromCollection(collectionName);

      // Filter by makeup type only
      final filtered = allProducts.where((product) {
        return product.makeupType
                .toLowerCase()
                .contains(makeupType.toLowerCase()) ||
            makeupType.toLowerCase().contains(product.makeupType.toLowerCase());
      }).toList();

      print('Found ${filtered.length} products of type $makeupType');
      return filtered.take(limit).toList();
    } catch (e) {
      print('Error in _getAnyProductsOfType: $e');
      return [];
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
      // Build query based on makeup type and matching criteria
      bool isBaseProduct = [
        'foundation',
        'concealer',
        'base',
        'skin tint',
        'bb cream',
        'powder'
      ].any((type) => makeupType.toLowerCase().contains(type));

      // Try exact match first
      List<MakeupProduct> products = await _tryExactMatch(
        collectionName: collectionName,
        makeupType: makeupType,
        skinTone: skinTone,
        undertone: undertone,
        isBaseProduct: isBaseProduct,
        limit: limit,
      );

      // If no products found with exact match, try flexible matching
      if (products.isEmpty) {
        products = await _tryFlexibleMatch(
          collectionName: collectionName,
          makeupType: makeupType,
          skinTone: skinTone,
          undertone: undertone,
          isBaseProduct: isBaseProduct,
          limit: limit,
        );
      }

      // If still no products found, try undertone-only match for base products
      if (products.isEmpty && isBaseProduct) {
        products = await _tryUndertoneOnlyMatch(
          collectionName: collectionName,
          makeupType: makeupType,
          undertone: undertone,
          limit: limit,
        );
      }

      // If still no products, get any products of the right type
      if (products.isEmpty) {
        products = await _tryAnyProductOfType(
          collectionName: collectionName,
          makeupType: makeupType,
          limit: limit,
        );
      }

      return products;
    } catch (e) {
      print('Error in _fetchProductsForType: $e');
      return [];
    }
  }

  // Try exact match first
  Future<List<MakeupProduct>> _tryExactMatch({
    required String collectionName,
    required String makeupType,
    required String skinTone,
    required String undertone,
    required bool isBaseProduct,
    required int limit,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

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

      query = query.limit(limit);
      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => MakeupProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error in exact match: $e');
      return [];
    }
  }

  // Try flexible matching as fallback
  Future<List<MakeupProduct>> _tryFlexibleMatch({
    required String collectionName,
    required String makeupType,
    required String skinTone,
    required String undertone,
    required bool isBaseProduct,
    required int limit,
  }) async {
    try {
      final allProducts = await _getAllProductsFromCollection(collectionName);
      return _filterProductsInMemory(
          allProducts, makeupType, skinTone, undertone, isBaseProduct, limit);
    } catch (e) {
      print('Error in flexible match: $e');
      return [];
    }
  }

  // Try undertone-only match for base products
  Future<List<MakeupProduct>> _tryUndertoneOnlyMatch({
    required String collectionName,
    required String makeupType,
    required String undertone,
    required int limit,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      // Only match undertone, not skin tone
      query = query.where('Undertone', isEqualTo: undertone);

      // Filter by makeup type if specified
      if (makeupType != 'all') {
        query = query.where('Makeup_Type', isEqualTo: makeupType);
      }

      query = query.limit(limit);
      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => MakeupProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error in undertone-only match: $e');
      return [];
    }
  }

  // Try any product of the right type
  Future<List<MakeupProduct>> _tryAnyProductOfType({
    required String collectionName,
    required String makeupType,
    required int limit,
  }) async {
    try {
      Query query = _firestore.collection(collectionName);

      // Only filter by makeup type
      if (makeupType != 'all') {
        query = query.where('Makeup_Type', isEqualTo: makeupType);
      }

      query = query.limit(limit);
      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => MakeupProduct.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error in any product type match: $e');
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
      // Create a list to store products with their match scores
      List<MapEntry<MakeupProduct, int>> scoredProducts = [];

      for (var product in products) {
        int score = 0;

        // Type matching (highest priority)
        bool typeMatch = product.makeupType
                .toLowerCase()
                .contains(makeupType.toLowerCase()) ||
            makeupType.toLowerCase().contains(product.makeupType.toLowerCase());
        if (typeMatch) score += 10;

        // Undertone matching (high priority)
        bool undertoneMatch = _isUndertoneMatch(product.undertone, undertone);
        if (undertoneMatch) score += 8;

        // Skin tone matching (for base products only)
        if (isBaseProduct && product.skinTone != null) {
          bool skinToneMatch = _isSkinToneMatch(product.skinTone!, skinTone);
          if (skinToneMatch) score += 5;
        }

        // Only add products that at least match the type
        if (typeMatch) {
          scoredProducts.add(MapEntry(product, score));
        }
      }

      // Sort by score (highest first)
      scoredProducts.sort((a, b) => b.value.compareTo(a.value));

      // Return the top N products
      return scoredProducts.take(limit).map((entry) => entry.key).toList();
    } catch (e) {
      print('Error in _filterProductsInMemory: $e');
      return [];
    }
  }

  // Check if undertones match (with flexible matching)
  bool _isUndertoneMatch(String productUndertone, String targetUndertone) {
    // Normalize undertones for comparison
    String normalizedProduct = productUndertone.toLowerCase().trim();
    String normalizedTarget = targetUndertone.toLowerCase().trim();

    // Direct match
    if (normalizedProduct == normalizedTarget) return true;

    // Check if product undertone contains target undertone or vice versa
    if (normalizedProduct.contains(normalizedTarget) ||
        normalizedTarget.contains(normalizedProduct)) return true;

    // Handle special cases for mixed undertones
    List<String> productParts =
        normalizedProduct.split(',').map((e) => e.trim()).toList();
    List<String> targetParts =
        normalizedTarget.split(',').map((e) => e.trim()).toList();

    // Check if any part matches
    for (var productPart in productParts) {
      for (var targetPart in targetParts) {
        if (productPart.contains(targetPart) ||
            targetPart.contains(productPart)) {
          return true;
        }
      }
    }

    return false;
  }

  // Check if skin tones match (with flexible matching)
  bool _isSkinToneMatch(String productSkinTone, String targetSkinTone) {
    // Normalize skin tones for comparison
    String normalizedProduct = productSkinTone.toLowerCase().trim();
    String normalizedTarget = targetSkinTone.toLowerCase().trim();

    // Direct match
    if (normalizedProduct == normalizedTarget) return true;

    // Check if product skin tone contains target skin tone or vice versa
    if (normalizedProduct.contains(normalizedTarget) ||
        normalizedTarget.contains(normalizedProduct)) return true;

    // Handle special cases for similar skin tones
    Map<String, List<String>> similarSkinTones = {
      'fair': ['light', 'porcelain'],
      'light': ['fair', 'porcelain'],
      'medium': ['tan', 'olive'],
      'tan': ['medium', 'olive'],
      'olive': ['medium', 'tan'],
      'dark': ['deep', 'rich'],
      'deep': ['dark', 'rich'],
    };

    // Check for similar skin tones
    for (var key in similarSkinTones.keys) {
      if (normalizedProduct.contains(key) &&
          similarSkinTones[key]!
              .any((tone) => normalizedTarget.contains(tone))) {
        return true;
      }
    }

    return false;
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
