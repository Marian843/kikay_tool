import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kikay/models/makeup_product.dart';

class ProductInfoPage extends StatelessWidget {
  final MakeupProduct product;
  final String? detectedSkinTone;
  final String? detectedUndertone;

  const ProductInfoPage({
    super.key,
    required this.product,
    this.detectedSkinTone,
    this.detectedUndertone,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4BBD3),
      body: Stack(
        children: [
          // Header Title
          Positioned(
            top: 40,
            left: 25,
            child: Text(
              'Kikay',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFDC1768),
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 40,
            right: 25,
            child: IconButton(
              icon: const Icon(Icons.subdirectory_arrow_left),
              color: const Color(0xFFDC1768),
              onPressed: () {
                Navigator.pop(context, '/output');
              },
            ),
          ),
          // Main Scrollable Content
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Product Image
                  Container(
                    width: screenWidth,
                    margin: const EdgeInsets.only(top: 20, bottom: 44),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E4F3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: product.fixedImageUrl != null &&
                            product.fixedImageUrl!.isNotEmpty
                        ? Image.network(
                            product.fixedImageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // If the primary image URL fails, try the imageLink as fallback
                              if (product.fixedImageLink != null &&
                                  product.fixedImageLink!.isNotEmpty) {
                                return Image.network(
                                  product.fixedImageLink!,
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
                                  errorBuilder: (context, error, stackTrace) =>
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

                  // Text Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        infoText(
                            'Name:', '${product.brand} ${product.productName}'),
                        infoText(
                            'Skin Tone:', detectedSkinTone ?? 'Not detected'),
                        infoText(
                            'Undertone:', detectedUndertone ?? 'Not detected'),
                        const SizedBox(height: 29),

                        // Shade Details Box
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC1768),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              detailHeader('Shade Details'),
                              detailBullet(
                                  'Shade Details:', product.fullShadeName),
                              detailBullet(
                                'Undertone Compatibility:',
                                'Best for ${product.undertone.toLowerCase()} undertones',
                              ),
                              detailBullet(
                                'Finish Type:',
                                product.finish ?? 'Not specified',
                              ),
                              detailBullet(
                                'Skin Tone:',
                                product.skinTone ?? 'Not specified',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Text.rich(
        TextSpan(
          text: '$label ',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF970B45),
          ),
          children: [
            TextSpan(
              text: value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                color: const Color(0xFF970B45),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget detailHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFF1E4F3),
      ),
    );
  }

  Widget detailBullet(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6),
      child: Text.rich(
        TextSpan(
          text: '• $label ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF1E4F3),
          ),
          children: [
            TextSpan(
              text: value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: const Color(0xFFF1E4F3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
