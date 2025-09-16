import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Data class to hold user preferences
class UserPreferences {
  // Base
  bool foundation;
  bool concealer;
  bool powder;
  bool bbCream;

  // Cheeks
  bool blush;
  bool highlighter;
  bool bronzer;

  // Eyes
  bool eyeshadow;
  bool eyeliner;
  bool mascara;

  // Lips
  bool lipstick;
  bool lipTint;
  bool lipOil;
  bool lipGloss;

  UserPreferences({
    this.foundation = false,
    this.concealer = false,
    this.powder = false,
    this.bbCream = false,
    this.blush = false,
    this.highlighter = false,
    this.bronzer = false,
    this.eyeshadow = false,
    this.eyeliner = false,
    this.mascara = false,
    this.lipstick = false,
    this.lipTint = false,
    this.lipOil = false,
    this.lipGloss = false,
  });

  // Get selected items as a map for easier passing
  Map<String, bool> toMap() {
    return {
      'foundation': foundation,
      'concealer': concealer,
      'powder': powder,
      'bbCream': bbCream,
      'blush': blush,
      'highlighter': highlighter,
      'bronzer': bronzer,
      'eyeshadow': eyeshadow,
      'eyeliner': eyeliner,
      'mascara': mascara,
      'lipstick': lipstick,
      'lipTint': lipTint,
      'lipOil': lipOil,
      'lipGloss': lipGloss,
    };
  }

  // Get only selected items
  List<String> getSelectedItems() {
    final selected = <String>[];
    final map = toMap();
    map.forEach((key, value) {
      if (value) selected.add(key);
    });
    return selected;
  }
}

class PreferencesPage extends StatefulWidget {
  final VoidCallback? onPressed;

  const PreferencesPage({super.key, this.onPressed});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  // User preferences
  final UserPreferences _preferences = UserPreferences();

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
    // Get the image path from the route arguments
    final imagePath = ModalRoute.of(context)?.settings.arguments as String?;

    print('PreferencesPage build called');
    print('Image path: $imagePath');
    print('Preferences: ${_preferences.toMap()}');

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
                  _preferences.foundation,
                  (v) => setState(() => _preferences.foundation = v!),
                ),
                buildCheckbox(
                  'Concealer',
                  _preferences.concealer,
                  (v) => setState(() => _preferences.concealer = v!),
                ),
                buildCheckbox(
                  'Powder',
                  _preferences.powder,
                  (v) => setState(() => _preferences.powder = v!),
                ),
                buildCheckbox(
                  'BB Cream',
                  _preferences.bbCream,
                  (v) => setState(() => _preferences.bbCream = v!),
                ),
              ]),
              buildCategory('Cheeks', [
                buildCheckbox(
                  'Blush',
                  _preferences.blush,
                  (v) => setState(() => _preferences.blush = v!),
                ),
                buildCheckbox(
                  'Highlighter',
                  _preferences.highlighter,
                  (v) => setState(() => _preferences.highlighter = v!),
                ),
                buildCheckbox(
                  'Bronzer',
                  _preferences.bronzer,
                  (v) => setState(() => _preferences.bronzer = v!),
                ),
              ]),
              buildCategory('Eyes', [
                buildCheckbox(
                  'Eyeshadow',
                  _preferences.eyeshadow,
                  (v) => setState(() => _preferences.eyeshadow = v!),
                ),
                buildCheckbox(
                  'Eyeliner',
                  _preferences.eyeliner,
                  (v) => setState(() => _preferences.eyeliner = v!),
                ),
                buildCheckbox(
                  'Mascara',
                  _preferences.mascara,
                  (v) => setState(() => _preferences.mascara = v!),
                ),
              ]),
              buildCategory('Lips', [
                buildCheckbox(
                  'Lipstick',
                  _preferences.lipstick,
                  (v) => setState(() => _preferences.lipstick = v!),
                ),
                buildCheckbox(
                  'Lip Tint',
                  _preferences.lipTint,
                  (v) => setState(() => _preferences.lipTint = v!),
                ),
                buildCheckbox(
                  'Lip Oil',
                  _preferences.lipOil,
                  (v) => setState(() => _preferences.lipOil = v!),
                ),
                buildCheckbox(
                  'Lip Gloss',
                  _preferences.lipGloss,
                  (v) => setState(() => _preferences.lipGloss = v!),
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
                onPressed: widget.onPressed ??
                    () {
                      print('Discover Your Best Shades button pressed');
                      print('Current preferences: ${_preferences.toMap()}');

                      // Get selected preferences
                      final selectedPrefs = _preferences.toMap();
                      print('Selected preferences: $selectedPrefs');

                      Navigator.pushNamed(
                        context,
                        '/output',
                        arguments: {
                          'imagePath': imagePath,
                          'skinTone': 'Fair',
                          'undertone': 'Neutral',
                          'preferences': selectedPrefs, // Pass preferences
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
