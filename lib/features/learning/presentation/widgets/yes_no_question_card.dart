import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YesNoQuestionCard extends StatefulWidget {
  final String question;
  final Function(bool) onAnswer;
  final int step;
  final int totalSteps;

  const YesNoQuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.step,
    required this.totalSteps,
  });

  @override
  State<YesNoQuestionCard> createState() => _YesNoQuestionCardState();
}

class _YesNoQuestionCardState extends State<YesNoQuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _cardAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _handleAnswer(bool answer) {
    _buttonAnimationController.forward().then((_) {
      widget.onAnswer(answer);
      _buttonAnimationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Penguin emoji
                    Text('🐧', style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 20),

                    // Question
                    Text(
                      widget.question,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 30),

                    // Step indicator
                    Text(
                      'Question ${widget.step} of ${widget.totalSteps}',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Answer buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAnswerButton(
                          text: 'YES',
                          color: const Color(0xFF2ECC71),
                          onTap: () => _handleAnswer(true),
                        ),
                        _buildAnswerButton(
                          text: 'NO',
                          color: const Color(0xFFE74C3C),
                          onTap: () => _handleAnswer(false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _buttonAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_buttonAnimationController.value * 0.1),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 100,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
