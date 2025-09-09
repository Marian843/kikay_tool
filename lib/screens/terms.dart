import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsPage extends StatefulWidget {
  final VoidCallback onNext;

  const TermsPage({super.key, required this.onNext});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF686BD),
      body: Stack(
        children: [
          // Top-left "Kikay" label
          Positioned(
            top: 40,
            left: 25,
            child: Text(
              'Kikay',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF1E4F3),
              ),
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Centered Title
                    Text(
                      'Terms & Conditions',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 26),

                    // Terms description
                    Text(
                      'Before using Kikay, please review the following:\n'
                      '✅ We analyze uploaded images solely for shade matching.\n'
                      '✅ Your data will be securely stored and used only for improving recommendation accuracy.\n'
                      '✅ By proceeding, you agree to our Privacy Policy and Terms of Use.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFF1E4F3),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Agreement checkbox
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreed = !_agreed;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(4),
                              color: _agreed
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                            child: _agreed
                                ? const Center(
                                    child: Text(
                                      '✓',
                                      style: TextStyle(
                                        color: Color(0xFFDC1768),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'I agree to the terms.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFF1E4F3),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Proceed button
                    GestureDetector(
                      onTap: () {
                        if (_agreed) {
                          widget.onNext();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please agree to the terms to continue.',
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 342,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4BBD3),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Start Matching!',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFDC1768),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
