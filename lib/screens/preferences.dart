import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreferencesPage extends StatefulWidget {
  final VoidCallback? onPressed;

  const PreferencesPage({super.key, this.onPressed});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  // Base
  bool foundation = false;
  bool concealer = false;
  bool powder = false;
  bool bbCream = false;

  // Cheeks
  bool blush = false;
  bool highlighter = false;
  bool bronzer = false;

  // Eyes
  bool eyeshadow = false;
  bool eyeliner = false;
  bool mascara = false;

  // Lips
  bool lipstick = false;
  bool lipTint = false;
  bool lipOil = false;
  bool lipGloss = false;

  Widget buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          activeColor: const Color(0xFFDC1768),
          onChanged: onChanged,
        ),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF372623),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCategory(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF970B45),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 0, children: children),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4BBD3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Text(
                'Kikay',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFDC1768),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Step-by-Step Guide',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC1768),
                ),
              ),
              const SizedBox(height: 30),

              // Step 2
              Text(
                'Step 2: Choose Your Preferences',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF372623),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select what makeup products you\'d like recommendations for - foundation, blush, lipstick, and more!',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF372623),
                ),
              ),
              const SizedBox(height: 24),

              buildCategory('Base Makeup', [
                buildCheckbox(
                  'Foundation',
                  foundation,
                  (v) => setState(() => foundation = v!),
                ),
                buildCheckbox(
                  'Concealer',
                  concealer,
                  (v) => setState(() => concealer = v!),
                ),
                buildCheckbox(
                  'Powder',
                  powder,
                  (v) => setState(() => powder = v!),
                ),
                buildCheckbox(
                  'BB Cream',
                  bbCream,
                  (v) => setState(() => bbCream = v!),
                ),
              ]),
              buildCategory('Cheeks', [
                buildCheckbox(
                  'Blush',
                  blush,
                  (v) => setState(() => blush = v!),
                ),
                buildCheckbox(
                  'Highlighter',
                  highlighter,
                  (v) => setState(() => highlighter = v!),
                ),
                buildCheckbox(
                  'Bronzer',
                  bronzer,
                  (v) => setState(() => bronzer = v!),
                ),
              ]),
              buildCategory('Eyes', [
                buildCheckbox(
                  'Eyeshadow',
                  eyeshadow,
                  (v) => setState(() => eyeshadow = v!),
                ),
                buildCheckbox(
                  'Eyeliner',
                  eyeliner,
                  (v) => setState(() => eyeliner = v!),
                ),
                buildCheckbox(
                  'Mascara',
                  mascara,
                  (v) => setState(() => mascara = v!),
                ),
              ]),
              buildCategory('Lips', [
                buildCheckbox(
                  'Lipstick',
                  lipstick,
                  (v) => setState(() => lipstick = v!),
                ),
                buildCheckbox(
                  'Lip Tint',
                  lipTint,
                  (v) => setState(() => lipTint = v!),
                ),
                buildCheckbox(
                  'Lip Oil',
                  lipOil,
                  (v) => setState(() => lipOil = v!),
                ),
                buildCheckbox(
                  'Lip Gloss',
                  lipGloss,
                  (v) => setState(() => lipGloss = v!),
                ),
              ]),

              Text(
                'Step 3: Get Your Results!',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF372623),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Our AI will analyze your image and suggest makeup that complements your undertone perfectly.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF372623),
                ),
              ),
              const SizedBox(height: 25),

              ElevatedButton(
                onPressed:
                    widget.onPressed ??
                    () {
                      Navigator.pushNamed(
                        context,
                        '/output',
                        arguments: {
                          'imagePath':
                              'path_to_your_image', // Replace with actual path
                          'skinTone': 'Fair', // Replace with actual skin tone
                          'undertone': 'Warm', // Replace with actual undertone
                        },
                      );
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1E4F3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                ),
                child: Text(
                  'Discover Your Best Shades!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC1768),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
