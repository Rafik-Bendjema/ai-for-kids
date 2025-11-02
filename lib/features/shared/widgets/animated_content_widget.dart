import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedContentWidget extends StatefulWidget {
  final String lottieUrl;
  final String text;
  final Duration typingSpeed;
  final double lottieHeight;
  final double lottieWidth;

  const AnimatedContentWidget({
    super.key,
    required this.lottieUrl,
    required this.text,
    this.typingSpeed = const Duration(milliseconds: 50),
    this.lottieHeight = 200,
    this.lottieWidth = 200,
  });

  @override
  State<AnimatedContentWidget> createState() => _AnimatedContentWidgetState();
}

class _AnimatedContentWidgetState extends State<AnimatedContentWidget>
    with TickerProviderStateMixin {
  late AnimationController _typingController;
  late Animation<int> _typingAnimation;
  String _displayedText = '';
  bool _isTypingComplete = false;

  @override
  void initState() {
    super.initState();
    _setupTypingAnimation();
    _startTyping();
  }

  void _setupTypingAnimation() {
    _typingController = AnimationController(
      duration: Duration(
        milliseconds: widget.text.length * widget.typingSpeed.inMilliseconds,
      ),
      vsync: this,
    );

    _typingAnimation = IntTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );

    _typingAnimation.addListener(() {
      setState(() {
        try {
          // Ensure proper UTF-16 handling
          final textLength = widget.text.length;
          final currentIndex = _typingAnimation.value.clamp(0, textLength);
          _displayedText = widget.text.substring(0, currentIndex);
          if (currentIndex == textLength) {
            _isTypingComplete = true;
          }
        } catch (e) {
          print('Text encoding error: $e');
          _displayedText = widget.text;
          _isTypingComplete = true;
        }
      });
    });
  }

  void _startTyping() {
    _typingController.forward();
  }

  Widget _buildLottieAnimation() {
    try {
      // Validate URL and text encoding
      if (widget.lottieUrl.isEmpty ||
          !(Uri.tryParse(widget.lottieUrl)?.hasAbsolutePath ?? false)) {
        return _buildFallbackAnimation();
      }

      return Lottie.network(
        widget.lottieUrl,
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
        errorBuilder: (context, error, stackTrace) {
          print('Lottie error: $error');
          return _buildFallbackAnimation();
        },
        frameRate: FrameRate.max,
        options: LottieOptions(enableMergePaths: true),
      );
    } catch (e) {
      print('Lottie network error: $e');
      return _buildFallbackAnimation();
    }
  }

  Widget _buildFallbackAnimation() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade100, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated brain icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: const Icon(
                  Icons.psychology,
                  size: 80,
                  color: Colors.blue,
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          // Brain emoji with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 0.1,
                child: Text('🧠', style: TextStyle(fontSize: 40)),
              );
            },
          ),
          const SizedBox(height: 10),
          // Subtle text
          Text(
            'Brain Power',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation with fallback
          SizedBox(
            height: widget.lottieHeight,
            width: widget.lottieWidth,
            child: _buildLottieAnimation(),
          ),

          const SizedBox(height: 30),

          // Typing Text Animation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              _displayedText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Typing indicator
          if (!_isTypingComplete) ...[
            const SizedBox(height: 20),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
