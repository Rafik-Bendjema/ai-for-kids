import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightMeter extends StatefulWidget {
  final String label;
  final double value;
  final Color color;
  final AnimationController animationController;
  final bool isBias;

  const WeightMeter({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.animationController,
    this.isBias = false,
  });

  @override
  State<WeightMeter> createState() => _WeightMeterState();
}

class _WeightMeterState extends State<WeightMeter>
    with SingleTickerProviderStateMixin {
  late Animation<double> _scaleAnimation;
  late AnimationController _valueAnimationController;
  late Animation<double> _valueAnimation;
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();

    // Scale animation tied to external controller
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Create a separate controller for value animation
    _valueAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _valueAnimation =
        Tween<double>(begin: 0.0, end: widget.value).animate(
          CurvedAnimation(
            parent: _valueAnimationController,
            curve: Curves.easeOutCubic,
          ),
        )..addListener(() {
          setState(() {
            _currentValue = _valueAnimation.value;
          });
        });

    // Start the initial animation
    _valueAnimationController.forward();
  }

  @override
  void didUpdateWidget(covariant WeightMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the value animation when weight changes
    if (oldWidget.value != widget.value) {
      _valueAnimation =
          Tween<double>(begin: _currentValue, end: widget.value).animate(
            CurvedAnimation(
              parent: _valueAnimationController,
              curve: Curves.easeOutCubic,
            ),
          )..addListener(() {
            setState(() {
              _currentValue = _valueAnimation.value;
            });
          });

      // Reset and replay the value animation
      _valueAnimationController.reset();
      _valueAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _valueAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.isBias ? 120 : 80,
            height: widget.isBias ? 100 : 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: widget.color.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label
                Text(
                  widget.label,
                  style: GoogleFonts.fredoka(
                    fontSize: widget.isBias ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Value display
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: widget.color, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _currentValue.toStringAsFixed(1),
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Visual bar
                Container(
                  width: 60,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_currentValue + 2) / 4, // Normalize to 0-1
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
