import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logo_painter.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late AnimationController _textController;
  late Animation<double> _textOpacity;

  late AnimationController _progressController;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations in sequence
    _logoController.forward().then((_) {
      _textController.forward();
    });
    
    _progressController.forward();

    // Transition to main content after delay
    Timer(const Duration(milliseconds: 3200), () {
      widget.onInitializationComplete();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // 1. Radial glow gradient in background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF221A05), // Dark golden/bronze glow center
                    Color(0xFF0F0F0F),
                    Color(0xFF050505), // Deep black outer
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // 2. Main Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(flex: 3),
                
                // Logo & Brand Name Container
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with Scale and Fade transition
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: 0.8 + (0.2 * _logoScale.value),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC107).withValues(alpha: 0.12),
                              blurRadius: 40,
                              spreadRadius: 8,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: CustomPaint(
                            painter: LogoPainter(
                              color: const Color(0xFFFFC107), // Beautiful gold
                              strokeWidth: 3.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    
                    // Brand text & Tagline with Fade transition
                    FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // English Brand Name
                          Text(
                            'Nagek',
                            style: GoogleFonts.outfit(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFFC107),
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          
                          // Arabic Brand Name
                          Text(
                            'نجيك',
                            style: GoogleFonts.cairo(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Tagline
                          Text(
                            'صيانة ذكية.. ثقة أكيدة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8C8269),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Spacer(flex: 3),
                
                // 3. Loading Indicator & Progress Bar at the Bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Linear gradient animated progress bar
                      AnimatedBuilder(
                        animation: _progressValue,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 2,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                              FractionallySizedBox(
                                widthFactor: _progressValue.value,
                                child: Container(
                                  height: 2,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF8C8269),
                                        Color(0xFFFFC107),
                                        Color(0xFF8C8269),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Loading Text
                      Text(
                        'جاري التحميل...',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
