import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids/features/learning/presentation/bloc/weights_cubit.dart';

class FreePlayScreen extends StatefulWidget {
  final VoidCallback onReset;

  const FreePlayScreen({super.key, required this.onReset});

  @override
  State<FreePlayScreen> createState() => _FreePlayScreenState();
}

class _FreePlayScreenState extends State<FreePlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _brainAnimationController;
  late AnimationController _answerAnimationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  bool _isRainy = false;
  bool _hasHomework = false;
  bool _isWeekend = false;
  String? _brainAnswer;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _brainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _brainAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _answerAnimationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _brainAnimationController.dispose();
    _answerAnimationController.dispose();
    super.dispose();
  }

  void _askBrain() {
    final input = [_isRainy ? 1 : 0, _hasHomework ? 1 : 0, _isWeekend ? 1 : 0];
    final prediction = context.read<WeightsCubit>().predict(input);
    final shouldPlay = prediction > 0.5;

    setState(() {
      _brainAnswer = shouldPlay
          ? 'Yes! Let\'s go play outside! 🎉'
          : 'No, better stay inside today. 😊';
      _showAnswer = true;
    });

    _brainAnimationController.forward().then((_) {
      _brainAnimationController.reset();
    });
    _answerAnimationController.forward();
  }

  void _resetQuestions() {
    setState(() {
      _isRainy = false;
      _hasHomework = false;
      _isWeekend = false;
      _brainAnswer = null;
      _showAnswer = false;
    });
    _answerAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Title
            Text(
              'Free Play Mode!',
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ask Penguin\'s brain anything!',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                color: const Color(0xFF7F8C8D),
              ),
            ),

            const SizedBox(height: 30),

            // Question cards
            _buildQuestionCard(
              title: 'Is it rainy?',
              value: _isRainy,
              onChanged: (value) => setState(() => _isRainy = value),
              emoji: '🌧️',
              color: const Color(0xFF3498DB),
            ),
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Do I have homework?',
              value: _hasHomework,
              onChanged: (value) => setState(() => _hasHomework = value),
              emoji: '📚',
              color: const Color(0xFFE74C3C),
            ),
            const SizedBox(height: 16),
            _buildQuestionCard(
              title: 'Is it the weekend?',
              value: _isWeekend,
              onChanged: (value) => setState(() => _isWeekend = value),
              emoji: '🎉',
              color: const Color(0xFF2ECC71),
            ),

            const SizedBox(height: 20),

            // Ask brain button
            AnimatedBuilder(
              animation: _brainAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: ElevatedButton(
                    onPressed: _askBrain,
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
                      'Ask Penguin\'s Brain! 🧠',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Brain answer
            if (_showAnswer)
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('🧠', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 10),
                          Text(
                            _brainAnswer!,
                            style: GoogleFonts.fredoka(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // Reset button
            TextButton(
              onPressed: _resetQuestions,
              child: Text(
                'Ask Different Questions',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Back to start button
            TextButton(
              onPressed: widget.onReset,
              child: Text(
                'Start Over',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: const Color(0xFF6C5CE7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required String emoji,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: value ? color : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: color),
        ],
      ),
    );
  }
}
