import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kikay/services/model_service.dart';
import 'package:kikay/services/makeup_service.dart';
import 'package:kikay/models/makeup_product.dart';

class ImageResultPage extends StatefulWidget {
  final String imagePath;
  final String skinTone;
  final String undertone;
  final ModelService modelService;
  final Map<String, bool>? preferences; // Add preferences parameter

  const ImageResultPage({
    super.key,
    required this.imagePath,
    required this.skinTone,
    required this.undertone,
    required this.modelService,
    this.preferences, // Make it optional
  });

  @override
  State<ImageResultPage> createState() => _ImageResultPageState();
}

class _ImageResultPageState extends State<ImageResultPage> {
  String? _predictedSkinTone;
  String? _predictedUndertone;
  bool _isLoading = true;
  String _errorMessage = '';
  final MakeupService _makeupService = MakeupService();
  Map<String, List<MakeupProduct>> _recommendations = {};
  bool _isLoadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      print('Starting image analysis...');

      // Debug: Print all widget properties
      print('Image path: ${widget.imagePath}');
      print('Skin tone: ${widget.skinTone}');
      print('Undertone: ${widget.undertone}');
      print('Preferences: ${widget.preferences}');
      print('Preferences type: ${widget.preferences?.runtimeType}');

      // Additional debugging
      if (widget.preferences != null) {
        print('Preferences keys: ${widget.preferences!.keys}');
        print('Preferences values: ${widget.preferences!.values}');
        widget.preferences!.forEach((key, value) {
          print('Preference $key: $value');
        });
      }

      // Check if the image file exists
      if (!File(widget.imagePath).existsSync()) {
        print('Image file does not exist: ${widget.imagePath}');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Image file not found';
        });
        return;
      }

      print('Running skin tone prediction...');
      // Run predictions using the model service
      final skinTonePrediction =
          widget.modelService.predictSkinTone(File(widget.imagePath));

      print('Running undertone prediction...');
      final undertonePrediction =
          widget.modelService.predictUnderTone(File(widget.imagePath));

      String finalSkinTone = widget.skinTone;
      String finalUndertone = widget.undertone;

      if (skinTonePrediction != null) {
        _predictedSkinTone =
            widget.modelService.getSkinToneLabel(skinTonePrediction);
        finalSkinTone = _predictedSkinTone!;
        print('Skin tone prediction: $_predictedSkinTone');
      } else {
        print('Skin tone prediction failed');
      }

      if (undertonePrediction != null) {
        _predictedUndertone =
            widget.modelService.getUnderToneLabel(undertonePrediction);
        finalUndertone = _predictedUndertone!;
        print('Undertone prediction: $_predictedUndertone');
      } else {
        print('Undertone prediction failed');
      }

      // Fetch makeup recommendations after analysis
      if (widget.preferences != null) {
        await _fetchRecommendations(finalSkinTone, finalUndertone);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error analyzing image: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error analyzing image: $e';
      });
    }
  }

  Future<void> _fetchRecommendations(String skinTone, String undertone) async {
    if (widget.preferences == null) return;

    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      // Use the actual detected values, not the initial widget values
      final actualSkinTone = _predictedSkinTone ?? widget.skinTone;
      final actualUndertone = _predictedUndertone ?? widget.undertone;

      print(
          'Using actual values - Skin Tone: $actualSkinTone, Undertone: $actualUndertone');

      final recommendations = await _makeupService.getRecommendedProducts(
        preferences: widget.preferences!,
        skinTone: actualSkinTone,
        undertone: actualUndertone,
        limit: 3, // Get 3 products per category
      );

      setState(() {
        _recommendations = recommendations;
        _isLoadingRecommendations = false;
      });

      print('Fetched ${recommendations.length} categories of recommendations');
    } catch (e) {
      print('Error fetching recommendations: $e');
      setState(() {
        _isLoadingRecommendations = false;
      });
    }
  }

  // Build product sections based on recommendations
  List<Widget> _buildProductSections() {
    if (_isLoadingRecommendations) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ];
    }

    if (_recommendations.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No recommendations found. Please check your preferences.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ];
    }

    final sections = <Widget>[];

    _recommendations.forEach((category, products) {
      sections.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildProductSection(
            context,
            title: '$category Recommendation/s',
            products: products,
            route: category.toLowerCase().contains('concealer')
                ? '/productinfo'
                : null,
          ),
        ),
      );
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final isAsset = widget.imagePath.startsWith('assets/');
    final fileExists = isAsset ? true : File(widget.imagePath).existsSync();
    print(widget.undertone);
    return Scaffold(
      backgroundColor: const Color(0xFFF4BBD3),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          'Error: $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kikay',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFDC1768),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.subdirectory_arrow_left,
                              color: Color(0xFFDC1768),
                            ),
                            onPressed: () =>
                                Navigator.pop(context, '/preferences'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your Personalized Makeup Match!',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFDC1768),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Uploaded Image Preview',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF372623),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E4F3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: isAsset
                              ? Image.asset(widget.imagePath, fit: BoxFit.cover)
                              : fileExists
                                  ? Image.file(File(widget.imagePath),
                                      fit: BoxFit.cover)
                                  : _buildErrorWidget(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Analysis Results',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFDC1768),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Detected Skin Tone: ${_predictedSkinTone ?? widget.skinTone}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF970B45),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Detected Undertone: ${_predictedUndertone ?? widget.undertone}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF970B45),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      _buildWardrobeColors(),
                      const SizedBox(height: 20),
                      // Add product sections based on preferences
                      ..._buildProductSections(),
                      const SizedBox(height: 40),
                    ],
                  ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Could not load image',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildWardrobeColors() {
    final colorSets = [
      {
        'colors': ['#DCAE96', '#A8BBA2', '#3A5A75'],
        'labels': ['Dusty Rose', 'Sage', 'Denim Blue'],
      },
      {
        'colors': ['#B8A398', '#B0B0B0', '#F5F5F5'],
        'labels': ['Taupe', 'Gray', 'Soft White'],
      },
      {
        'colors': ['#FFF4B2', '#AEEEEE', '#C49BBB'],
        'labels': ['Soft Yellow', 'Aqua', 'Mauve'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Wardrobe Color Suggestions',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFDC1768),
          ),
        ),
        const SizedBox(height: 10),
        ...colorSets.map((set) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(set['colors']!.length, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse('0xFF${set['colors']![i].substring(1)}'),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(set['labels']!.length, (i) {
                  return Container(
                    width: 70,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      set['labels']![i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF372623),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProductSection(
    BuildContext context, {
    required String title,
    required List<MakeupProduct> products,
    String? route,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFDC1768),
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (_, i) {
              final product = products[i];
              final card = Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Builder(builder: (context) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          color: const Color(0xFFF8F8F8),
                          child: product.fixedImageUrl != null &&
                                  product.fixedImageUrl!.isNotEmpty
                              ? Image.network(
                                  product.fixedImageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    // If the primary image URL fails, try the imageLink as fallback
                                    // This is especially useful for Google Drive links
                                    if (product.fixedImageLink != null &&
                                        product.fixedImageLink!.isNotEmpty) {
                                      return Image.network(
                                        product.fixedImageLink!,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: const Color(0xFFF0F0F0),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Color(0xFFCCCCCC),
                                            size: 40,
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                      color: const Color(0xFFF0F0F0),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Color(0xFFCCCCCC),
                                        size: 40,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: const Color(0xFFF0F0F0),
                                  child: const Icon(
                                    Icons.image,
                                    color: Color(0xFFCCCCCC),
                                    size: 40,
                                  ),
                                ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.brand,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.productName,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF666666),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1E4F3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.shadeName,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFDC1768),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.finish != null &&
                              product.finish!.isNotEmpty)
                            Text(
                              product.finish!,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: const Color(0xFF999999),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              return GestureDetector(
                onTap: route != null && i == 0
                    ? () => Navigator.pushNamed(context, route)
                    : null,
                child: card,
              );
            },
          ),
        ),
      ],
    );
  }
}
