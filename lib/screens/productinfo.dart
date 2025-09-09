import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductInfoPage extends StatelessWidget {
  const ProductInfoPage({super.key});

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
                  // Product Image Placeholder
                  Container(
                    width: screenWidth,
                    height: 299,
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
                    alignment: Alignment.center,
                    child: Text(
                      'Product Image here.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Text Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        infoText('Name:', '[Product Name]'),
                        infoText('Detected Skin Tone:', '[Skin Tone Category]'),
                        infoText('Detected Undertone:', '[Warm/Cool/Neutral]'),
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
                              detailBullet('Shade Details:', '[Exact Shade]'),
                              detailBullet(
                                'Undertone Compatibility:',
                                '(e.g., "Best for warm undertones")',
                              ),
                              detailBullet(
                                'Finish Type:',
                                '(Matte, Glossy, Dewy, Satin, etc.)',
                              ),
                              detailBullet(
                                'Coverage (if applicable):',
                                '(Sheer, Medium, Full)',
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
