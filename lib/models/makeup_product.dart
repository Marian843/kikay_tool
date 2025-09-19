class MakeupProduct {
  final String id;
  final String makeupType;
  final String brand;
  final String productName;
  final String shadeName;
  final String? shadeDescription;
  final String? finish;
  final String undertone;
  final String? skinTone;
  final String? skinToneCategory;
  final String? imageUrl;
  final String? imageLink;
  final double? price;

  MakeupProduct({
    required this.id,
    required this.makeupType,
    required this.brand,
    required this.productName,
    required this.shadeName,
    this.shadeDescription,
    this.finish,
    required this.undertone,
    this.skinTone,
    this.skinToneCategory,
    this.imageUrl,
    this.imageLink,
    this.price,
  });

  factory MakeupProduct.fromFirestore(dynamic data, String id) {
    final Map<String, dynamic> mapData = data as Map<String, dynamic>;

    String? imageUrl = mapData['Image'] ??
        mapData['image'] ??
        mapData['Image Link'] ??
        mapData['image_link'];

    // Fix Google Drive URLs
    if (imageUrl != null && imageUrl.contains('drive.google.com')) {
      imageUrl = fixGoogleDriveUrl(imageUrl);
    }

    // Parse price from Firestore
    double? price;
    if (mapData['Price'] != null) {
      if (mapData['Price'] is double) {
        price = mapData['Price'];
      } else if (mapData['Price'] is int) {
        price = (mapData['Price'] as int).toDouble();
      } else if (mapData['Price'] is String) {
        price = double.tryParse(mapData['Price']);
      }
    }

    return MakeupProduct(
      id: id,
      makeupType: mapData['Makeup_Type'] ?? mapData['makeup_type'] ?? '',
      brand: mapData['Brand'] ?? mapData['brand'] ?? '',
      productName: mapData['Product_Name'] ?? mapData['product_name'] ?? '',
      shadeName: mapData['Shade_Name'] ?? mapData['shade_name'] ?? '',
      shadeDescription:
          mapData['Shade_Description'] ?? mapData['shade_description'],
      finish: mapData['Finish'] ?? mapData['finish'],
      undertone: mapData['Undertone'] ?? mapData['undertone'] ?? '',
      skinTone: mapData['Skintone'] ?? mapData['skintone'],
      skinToneCategory:
          mapData['Skintone_Category'] ?? mapData['skintone_category'],
      imageUrl: imageUrl,
      imageLink: mapData['Image Link'] ?? mapData['image_link'],
      price: price,
    );
  }

  static String? fixGoogleDriveUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Handle Google Drive sharing URLs
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

  factory MakeupProduct.fromCsv(Map<String, dynamic> data) {
    // Parse price from CSV
    double? price;
    if (data['Price'] != null) {
      if (data['Price'] is double) {
        price = data['Price'];
      } else if (data['Price'] is int) {
        price = (data['Price'] as int).toDouble();
      } else if (data['Price'] is String) {
        price = double.tryParse(data['Price']);
      }
    }

    return MakeupProduct(
      id: '${data['Brand']}_${data['Shade_Name']}'.replaceAll(' ', '_'),
      makeupType: data['Makeup_Type'] ?? '',
      brand: data['Brand'] ?? '',
      productName: data['Product_Name'] ?? '',
      shadeName: data['Shade_Name'] ?? '',
      shadeDescription: data['Shade_Description'],
      finish: data['Finish'],
      undertone: data['Undertone'] ?? '',
      skinTone: data['Skintone'],
      skinToneCategory: data['Skintone_Category'],
      imageUrl: data['Image'],
      imageLink: data['Image Link'],
      price: price,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Makeup_Type': makeupType,
      'Brand': brand,
      'Product_Name': productName,
      'Shade_Name': shadeName,
      'Shade_Description': shadeDescription,
      'Finish': finish,
      'Undertone': undertone,
      'Skintone': skinTone,
      'Skintone_Category': skinToneCategory,
      'Image': imageUrl,
      'Image Link': imageLink,
      'Price': price,
    };
  }

  String get displayName => '$brand $productName';
  String get fullShadeName =>
      '$shadeName${shadeDescription != null ? ' - $shadeDescription' : ''}';

  // Get the fixed image URL that handles Google Drive links
  String? get fixedImageUrl => fixGoogleDriveUrl(imageUrl);

  // Get the fixed image link that handles Google Drive links
  String? get fixedImageLink => fixGoogleDriveUrl(imageLink);

  bool matchesSkinTone(String targetSkinTone) {
    if (skinTone == null) return false;
    return skinTone!.toLowerCase().contains(targetSkinTone.toLowerCase());
  }

  bool matchesUndertone(String targetUndertone) {
    return undertone.toLowerCase().contains(targetUndertone.toLowerCase());
  }

  bool matchesBoth(String targetSkinTone, String targetUndertone) {
    // For base products (foundation, concealer), match both skin tone and undertone
    if (['foundation', 'concealer', 'base', 'skin tint', 'bb cream']
        .any((type) => makeupType.toLowerCase().contains(type))) {
      return matchesSkinTone(targetSkinTone) &&
          matchesUndertone(targetUndertone);
    }

    // For other products (eye, lip, blush), match undertone only
    return matchesUndertone(targetUndertone);
  }
}
