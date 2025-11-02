import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrainRevisingScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final AnimationController animationController;

  const BrainRevisingScreen({
    super.key,
    required this.onContinue,
    required this.animationController,
  });

  @override
  State<BrainRevisingScreen> createState() => _BrainRevisingScreenState();
}

class _BrainRevisingScreenState extends State<BrainRevisingScreen>
    with TickerProviderStateMixin {
  late AnimationController _textAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _textAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _textAnimationController.forward();
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated brain
          AnimatedBuilder(
            animation: widget.animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: widget.animationController.value * 0.1,
                child: Transform.scale(
                  scale: 1.0 + (widget.animationController.value * 0.2),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6C5CE7),
                          Color(0xFFA29BFE),
                          Color(0xFF74B9FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🧠', style: TextStyle(fontSize: 100)),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Animated text
          AnimatedBuilder(
            animation: _textAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        'Penguin\'s Brain is Revising!',
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'My brain is updating the weights\nbased on what you taught me!',
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          color: const Color(0xFF7F8C8D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 60),

          // Animated thinking dots
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale:
                              0.5 +
                              (0.5 *
                                  (1 -
                                      (_rotationAnimation.value - index * 0.3)
                                          .abs()
                                          .clamp(0.0, 1.0))),
                          child: child,
                        );
                      },
                      child: Container(),
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 40),

          // Continue button
          AnimatedBuilder(
            animation: _textAnimationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    'Continue to Free Play!',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
