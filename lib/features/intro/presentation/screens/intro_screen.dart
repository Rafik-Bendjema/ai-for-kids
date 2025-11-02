import 'package:flutter/material.dart';
import 'package:kids/features/shared/widgets/flexible_animation_widget.dart';
import 'package:kids/features/shared/widgets/custom_button.dart';
import 'package:kids/features/learning/presentation/screens/learning_game_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids/features/learning/presentation/bloc/weights_cubit.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Sample content for the intro - you can modify these
  final List<Map<String, String>> _introContent = [
    {
      'animationUrl': 'gif1.gif',
      'text': 'Hi! iam pengoon , let me intreduce you to my brain',
    },
    {
      'animationUrl': 'gif2.gif',
      'text': 'this is my brain, he is my little decisions maker',
    },
    {
      'animationUrl': 'gif3.gif',
      'text':
          'Just like your brain has neurons connected by wires, AI has something similar!',
    },
    {
      'animationUrl': 'gif4.gif',
      'text': 'These connections have different strengths, just like muscles!',
    },
    {
      'animationUrl': 'gif5.gif',
      'text':
          'When you learn something new, your brain changes these connections!',
    },
    {
      'animationUrl': 'gif6.gif',
      'text': 'AI learns the same way! Let us explore this together!',
    },
  ];

  void _nextPage() {
    if (_currentPage < _introContent.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to learning game with BLoC provider
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => WeightsCubit(),
            child: const LearningGameScreen(),
          ),
        ),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Introduction',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _introContent.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Content pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _introContent.length,
              itemBuilder: (context, index) {
                final content = _introContent[index];
                return FlexibleAnimationWidget(
                  isAsset: true,
                  animationPath: content['animationUrl'] ?? '',
                  text: content['text'] ?? '',
                  animationHeight: 250,
                  animationWidth: 250,
                );
              },
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _previousPage,
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                else
                  const SizedBox(width: 80),

                // Next button
                CustomButton(
                  text: _currentPage == _introContent.length - 1
                      ? 'Finish'
                      : 'Next',
                  onPressed: _nextPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
