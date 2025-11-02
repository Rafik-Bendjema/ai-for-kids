import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:kids/features/learning/presentation/widgets/weight_meter.dart';
import 'package:kids/features/learning/presentation/widgets/yes_no_question_card.dart';
import 'package:kids/features/learning/presentation/widgets/brain_revising_screen.dart';
import 'package:kids/features/learning/presentation/widgets/free_play_screen.dart';
import 'package:kids/features/learning/presentation/widgets/teach_mode_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids/features/learning/presentation/bloc/weights_cubit.dart';

enum Phase { modelAsks, revising, teachMode, freePlay }

class LearningGameScreen extends StatefulWidget {
  const LearningGameScreen({super.key});

  @override
  State<LearningGameScreen> createState() => _LearningGameScreenState();
}

class _LearningGameScreenState extends State<LearningGameScreen>
    with TickerProviderStateMixin {
  // Phases: model asks (quiz) -> revising -> teach mode -> free play

  Phase _phase = Phase.modelAsks;
  int _currentStep = 0;

  // Generated scenarios for model-asks phase
  late final List<Map<String, dynamic>> _questions;

  // Values read from BLoC when building
  double get _weight1 => context.read<WeightsCubit>().state.wRainy;
  double get _weight2 => context.read<WeightsCubit>().state.wHomework;
  double get _weight3 => context.read<WeightsCubit>().state.wWeekend;
  double get _bias => context.read<WeightsCubit>().state.bias;

  // Animation controllers
  late AnimationController _weightAnimationController;
  late AnimationController _brainAnimationController;

  @override
  void initState() {
    super.initState();
    _questions = _generateScenarios();
    _weightAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _brainAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _weightAnimationController.dispose();
    _brainAnimationController.dispose();
    super.dispose();
  }

  void _answerQuestion(bool answer) {
    if (_phase != Phase.modelAsks || _currentStep >= _questions.length) return;

    final question = _questions[_currentStep];
    final input = question['input'] as List<int>;
    final int target = answer ? 1 : 0; // learn from the kid's answer

    // Calculate current prediction
    final prediction = _calculatePrediction(input);
    // Always update weights (gradient step); don't skip when "correct"
    _updateWeights(input, target, prediction);

    setState(() {
      _currentStep++;
      if (_currentStep >= _questions.length) {
        _phase = Phase.revising;
      }
    });

    // Animate weight changes
    _weightAnimationController.forward().then((_) {
      _weightAnimationController.reset();
    });
  }

  double _calculatePrediction(List<int> input) {
    final sum =
        _weight1 * input[0] + _weight2 * input[1] + _weight3 * input[2] + _bias;
    return 1 / (1 + pow(e, -sum)); // Sigmoid activation
  }

  void _updateWeights(List<int> input, int target, double prediction) {
    const learningRate = 0.2;
    final error = target - prediction;
    print("updating wights");
    context.read<WeightsCubit>().learn(
      input,
      target,
      learningRate: learningRate,
    );
  }

  void _startBrainRevising() {
    _brainAnimationController.forward();
  }

  void _goToFreePlay() {
    setState(() {
      _phase = Phase.freePlay;
    });
  }

  void _resetGame() {
    setState(() {
      _currentStep = 0;
      _phase = Phase.modelAsks;
    });
    context.read<WeightsCubit>().reset();
    _weightAnimationController.reset();
    _brainAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Penguin\'s Brain Learning',
          style: GoogleFonts.fredoka(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_phase) {
      case Phase.modelAsks:
        return _buildQuizScreen();
      case Phase.revising:
        return BrainRevisingScreen(
          onContinue: () {
            setState(() {
              _phase = Phase.teachMode;
            });
          },
          animationController: _brainAnimationController,
        );
      case Phase.teachMode:
        return TeachModeScreen(
          onConfirm: (rainy, homework, weekend, kidSaysPlay) {
            final input = [rainy ? 1 : 0, homework ? 1 : 0, weekend ? 1 : 0];
            final target = kidSaysPlay ? 1 : 0;
            final prediction = _calculatePrediction(input);
            _updateWeights(input, target, prediction);
            _weightAnimationController.forward().then((_) {
              _weightAnimationController.reset();
            });
          },
          onDone: _goToFreePlay,
          weightAnimationController: _weightAnimationController,
        );
      case Phase.freePlay:
        return FreePlayScreen(onReset: _resetGame);
    }
  }

  Widget _buildQuizScreen() {
    final question = _questions[_currentStep];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _questions.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentStep >= index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentStep >= index
                        ? const Color(0xFF4A90E2)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Weight meters
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Penguin\'s Brain Weights',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<WeightsCubit, WeightsState>(
                  builder: (context, state) {
                    print("here is the state ${state.toString()}");
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        WeightMeter(
                          label: 'Rainy',
                          value: state.wRainy,
                          color: const Color(0xFF3498DB),
                          animationController: _weightAnimationController,
                        ),
                        WeightMeter(
                          label: 'Homework',
                          value: state.wHomework,
                          color: const Color(0xFFE74C3C),
                          animationController: _weightAnimationController,
                        ),
                        WeightMeter(
                          label: 'Weekend',
                          value: state.wWeekend,
                          color: const Color(0xFF2ECC71),
                          animationController: _weightAnimationController,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<WeightsCubit, WeightsState>(
                  builder: (context, state) {
                    return WeightMeter(
                      label: 'Bias',
                      value: state.bias,
                      color: const Color(0xFF9B59B6),
                      animationController: _weightAnimationController,
                      isBias: true,
                    );
                  },
                ),
              ],
            ),
          ),

          // Question card
          Expanded(
            child: YesNoQuestionCard(
              question: question['question'] as String,
              onAnswer: _answerQuestion,
              step: _currentStep + 1,
              totalSteps: _questions.length,
            ),
          ),
        ],
      ),
    );
  }

  // Create a diverse set of model-asks scenarios
  List<Map<String, dynamic>> _generateScenarios() {
    final List<Map<String, dynamic>> scenarios = [];
    const labels = ['rainy', 'homework', 'weekend'];
    // All 8 combinations
    for (int r = 0; r <= 1; r++) {
      for (int h = 0; h <= 1; h++) {
        for (int w = 0; w <= 1; w++) {
          final input = [r, h, w];
          scenarios.add({
            'question': _scenarioToQuestion(input, labels),
            'input': input,
          });
        }
      }
    }
    // Add a few extra mixed phrasings
    scenarios.addAll([
      {
        'question': 'It is sunny, but I have homework. Should I play?',
        'input': [0, 1, 0],
      },
      {
        'question': 'It\'s rainy and the weekend. Should I play?',
        'input': [1, 0, 1],
      },
      {
        'question': 'No rain, no homework, but not weekend. Should I play?',
        'input': [0, 0, 0],
      },
    ]);
    return scenarios;
  }

  String _scenarioToQuestion(List<int> input, List<String> labels) {
    final rainy = input[0] == 1 ? 'rainy' : 'not rainy';
    final homework = input[1] == 1 ? 'I have homework' : 'no homework';
    final weekend = input[2] == 1 ? 'the weekend' : 'not the weekend';
    return 'It is $rainy, $homework, and it\'s $weekend. Should I play?';
  }
}
