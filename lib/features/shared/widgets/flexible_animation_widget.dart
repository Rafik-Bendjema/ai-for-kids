import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gif/gif.dart';

class FlexibleAnimationWidget extends StatefulWidget {
  final String animationPath; // Can be network URL or asset path
  final String text;
  final Duration typingSpeed;
  final double animationHeight;
  final double animationWidth;
  final AnimationType animationType;
  final bool isAsset; // New parameter to specify if it's an asset

  const FlexibleAnimationWidget({
    super.key,
    required this.animationPath,
    required this.text,
    this.typingSpeed = const Duration(milliseconds: 50),
    this.animationHeight = 200,
    this.animationWidth = 200,
    this.animationType = AnimationType.auto,
    this.isAsset = false, // Default to network
  });

  @override
  State<FlexibleAnimationWidget> createState() =>
      _FlexibleAnimationWidgetState();
}

enum AnimationType {
  auto, // Automatically detect based on path
  lottie,
  gif,
  fallback,
}

class _FlexibleAnimationWidgetState extends State<FlexibleAnimationWidget>
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

  AnimationType _detectAnimationType() {
    if (widget.animationType != AnimationType.auto) {
      return widget.animationType;
    }

    final path = widget.animationPath.toLowerCase();
    if (path.isEmpty) return AnimationType.fallback;
    if (path.contains('.gif')) return AnimationType.gif;
    if (path.contains('.json')) return AnimationType.lottie;
    if (path.contains('giphy.com') || path.contains('tenor.com'))
      return AnimationType.gif;
    return AnimationType.fallback;
  }

  Widget _buildAnimation() {
    final animationType = _detectAnimationType();

    switch (animationType) {
      case AnimationType.lottie:
        return _buildLottieAnimation();
      case AnimationType.gif:
        return _buildGifAnimation();
      case AnimationType.fallback:
      default:
        return _buildFallbackAnimation();
    }
  }

  Widget _buildLottieAnimation() {
    try {
      if (widget.animationPath.isEmpty) {
        return _buildFallbackAnimation();
      }

      if (widget.isAsset) {
        // Load Lottie from assets
        return Lottie.asset(
          widget.animationPath,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
          errorBuilder: (context, error, stackTrace) {
            print('Lottie asset error: $error');
            return _buildFallbackAnimation();
          },
          frameRate: FrameRate.max,
          options: LottieOptions(enableMergePaths: true),
        );
      } else {
        // Load Lottie from network
        if (!(Uri.tryParse(widget.animationPath)?.hasAbsolutePath ?? false)) {
          return _buildFallbackAnimation();
        }

        return Lottie.network(
          widget.animationPath,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
          errorBuilder: (context, error, stackTrace) {
            print('Lottie network error: $error');
            return _buildFallbackAnimation();
          },
          frameRate: FrameRate.max,
          options: LottieOptions(enableMergePaths: true),
        );
      }
    } catch (e) {
      print('Lottie error: $e');
      return _buildFallbackAnimation();
    }
  }

  Widget _buildGifAnimation() {
    try {
      if (widget.animationPath.isEmpty) {
        return _buildFallbackAnimation();
      }

      if (widget.isAsset) {
        // Load GIF from assets
        return Gif(
          image: AssetImage("assets/gif/${widget.animationPath}" ),
          autostart: Autostart.loop,
          placeholder: (context) => _buildFallbackAnimation(),
        );
      } else {
        // Load GIF from network
        return Gif(
          image: NetworkImage(widget.animationPath),
          autostart: Autostart.loop,
          placeholder: (context) => _buildFallbackAnimation(),
        );
      }
    } catch (e) {
      print('GIF error: $e');
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
          // Animation (Lottie, GIF, or Fallback)
          SizedBox(
            height: widget.animationHeight,
            width: widget.animationWidth,
            child: _buildAnimation(),
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