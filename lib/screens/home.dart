import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  /// Open custom camera screen
  void _openCameraScreen() {
    Navigator.pushNamed(context, '/camera');
  }

  /// Pick image from gallery → go to ResultPage
  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return; // ✅ Guard against context use after async
    if (pickedFile != null) {
      Navigator.pushNamed(
        context,
        '/result', // make sure route is '/result'
        arguments: pickedFile.path, // send selected image path
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4BBD3),
      body: SafeArea(
        child: Stack(
          children: [
            // App title
            Positioned(
              top: 20,
              left: 25,
              child: Text(
                'Kikay',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFF1E4F3),
                ),
              ),
            ),

            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Step-by-Step Guide',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFF1E4F3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),

                      _buildStepTitle('Step 1: Upload your image'),
                      const SizedBox(height: 6),
                      _buildStepDescription(
                        'Snap a new photo or select one from your gallery. Ensure good lighting for the most accurate results.',
                      ),
                      const SizedBox(height: 28),

                      // Camera button (custom screen)
                      _buildRoundedButton(
                        label: 'Camera',
                        icon: Icons.camera_alt,
                        onPressed: _openCameraScreen,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'or',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF372623),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Gallery button → goes to ResultPage
                      _buildRoundedButton(
                        label: 'Gallery',
                        icon: Icons.image,
                        onPressed: _pickFromGallery,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Styled step title
  Widget _buildStepTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF372623),
        ),
      ),
    );
  }

  /// 🔹 Styled step description
  Widget _buildStepDescription(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF372623),
        ),
      ),
    );
  }

  /// 🔹 Custom rounded button
  Widget _buildRoundedButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: const Color(0xFFDC1768)),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFDC1768),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF1E4F3),
        elevation: 6,
        shadowColor: Colors.black.withAlpha(30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
      ),
    );
  }
}
