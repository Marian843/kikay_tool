import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kikay/services/model_service.dart';

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

      if (skinTonePrediction != null) {
        _predictedSkinTone =
            widget.modelService.getSkinToneLabel(skinTonePrediction);
        print('Skin tone prediction: $_predictedSkinTone');
      } else {
        print('Skin tone prediction failed');
      }

      if (undertonePrediction != null) {
        _predictedUndertone =
            widget.modelService.getUnderToneLabel(undertonePrediction);
        print('Undertone prediction: $_predictedUndertone');
      } else {
        print('Undertone prediction failed');
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

  // Get selected preferences
  List<String> _getSelectedPreferences() {
    if (widget.preferences == null) {
      print('No preferences data received');
      return [];
    }
    
    final selected = <String>[];
    widget.preferences!.forEach((key, value) {
      if (value) selected.add(key);
    });
    print('Selected preferences: $selected');
    return selected;
  }

  // Build product sections based on selected preferences
  List<Widget> _buildProductSections() {
    final selected = _getSelectedPreferences();
    final sections = <Widget>[];
    
    // Define all possible product sections
    final allSections = {
      'concealer': 'Concealer Recommendation/s',
      'foundation': 'Foundation Recommendation/s',
      'powder': 'Powder Recommendation/s',
      'bbCream': 'BB Cream Recommendation/s',
      'blush': 'Blush Recommendation/s',
      'highlighter': 'Highlighter Recommendation/s',
      'bronzer': 'Bronzer Recommendation/s',
      'eyeshadow': 'Eyeshadow Recommendation/s',
      'eyeliner': 'Eyeliner Recommendation/s',
      'mascara': 'Mascara Recommendation/s',
      'lipstick': 'Lipstick Recommendation/s',
      'lipTint': 'Lip Tint Recommendation/s',
      'lipOil': 'Lip Oil Recommendation/s',
      'lipGloss': 'Lip Gloss Recommendation/s',
    };
    
    // Add sections only for selected preferences
    allSections.forEach((key, title) {
      if (selected.contains(key) || selected.isEmpty) {
        // If no preferences are selected, show all sections
        sections.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _buildProductSection(
              context,
              title: title,
              route: key == 'concealer' ? '/productinfo' : null, // Only link concealer to product info
            ),
          ),
        );
      }
    });
    
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final isAsset = widget.imagePath.startsWith('assets/');
    final fileExists = isAsset ? true : File(widget.imagePath).existsSync();

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
        }),
      ],
    );
  }

  Widget _buildProductSection(
    BuildContext context, {
    required String title,
    String? route,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF970B45),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            padding: const EdgeInsets.only(right: 12),
            itemBuilder: (_, i) {
              final box = Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF686BD),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(blurRadius: 4, color: Colors.black26),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Product Image Here',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1E4F3),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Brand Name',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Shade Name',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (i == 0 && route != null) {
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, route),
                  child: box,
                );
              }

              return box;
            },
          ),
        ),
      ],
    );
  }
}