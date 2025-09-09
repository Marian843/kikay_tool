import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const KikayApp());
}

class KikayApp extends StatelessWidget {
  const KikayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kikay Product Detail',
      home: const ProductDetailPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kikayPink = Color(0xFFFFC1E3);
    const Color kikayHotPink = Color(0xFFFF69B4);
    const Color kikayTextColor = Color(0xFF333333);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'kikay',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: kikayHotPink,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Product Image
            Center(
              child: Image.network(
                'https://via.placeholder.com/200',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Product Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: Radiant Glow Foundation',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: kikayTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Brand: Glow Up Cosmetics',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: kikayTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price Range: ₱499 - ₱699',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: kikayTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Shade Details Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: kikayPink,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shade Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kikayHotPink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Shade Name: Warm Beige',
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Undertone Compatibility: Best for warm undertones',
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Finish Type: Dewy',
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Coverage: Medium',
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
