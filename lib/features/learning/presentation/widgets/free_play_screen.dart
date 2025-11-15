import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids/features/learning/presentation/bloc/neural_network_cubit.dart';

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
    final prediction = context.read<NeuralNetworkCubit>().predict(input);
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
    return Material(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F4FD), Color(0xFFF0F8FF)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title
              Text(
                'Playtime Planning Committee 🏛️',
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<NeuralNetworkCubit, NeuralNetworkState>(
                builder: (context, state) {
                  final isPhaseI = context.read<NeuralNetworkCubit>().isPhaseI;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isPhaseI
                          ? const Color(0xFF3498DB)
                          : const Color(0xFF2ECC71),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPhaseI
                          ? 'Phase I: Learning Priority Settings 🎯'
                          : 'Phase II: Advanced Tuning ⚙️',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Accuracy Score
              BlocBuilder<NeuralNetworkCubit, NeuralNetworkState>(
                builder: (context, state) {
                  final accuracy = context
                      .read<NeuralNetworkCubit>()
                      .calculateAccuracy();
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: accuracy > 0.7
                            ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
                            : accuracy > 0.4
                            ? [const Color(0xFFF39C12), const Color(0xFFE67E22)]
                            : [
                                const Color(0xFFE74C3C),
                                const Color(0xFFC0392B),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🎯 Committee Accuracy: ',
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${(accuracy * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // CONSOLE 1: Fact Cards (Input Display)
              _buildFactCardsConsole(),

              const SizedBox(height: 20),

              // CONSOLE 2: Planning Committee (Hidden Layer)
              _buildPlanningCommitteeConsole(),

              const SizedBox(height: 20),

              // CONSOLE 3: Kid's Brain (Output Layer)
              _buildKidsBrainConsole(),

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
                        'Ask the Committee! 🧠',
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

              // Dataset preview
              _buildDatasetPreview(),

              const SizedBox(height: 20),

              // Reset button
              TextButton(
                onPressed: _resetQuestions,
                child: Text(
                  'Reset Questions',
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
      ),
    );
  }

  // CONSOLE 1: Fact Cards (Input Display)
  Widget _buildFactCardsConsole() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Text(
                'Fact Cards',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'What are the facts today?',
            style: GoogleFonts.fredoka(
              fontSize: 14,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 20),
          _buildFactCard(
            title: 'Is it rainy?',
            value: _isRainy,
            onChanged: (value) => setState(() => _isRainy = value),
            emoji: '🌧️',
            color: const Color(0xFF3498DB),
          ),
          const SizedBox(height: 12),
          _buildFactCard(
            title: 'Do I have homework?',
            value: _hasHomework,
            onChanged: (value) => setState(() => _hasHomework = value),
            emoji: '📚',
            color: const Color(0xFFE74C3C),
          ),
          const SizedBox(height: 12),
          _buildFactCard(
            title: 'Is it the weekend?',
            value: _isWeekend,
            onChanged: (value) => setState(() => _isWeekend = value),
            emoji: '🎉',
            color: const Color(0xFF2ECC71),
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required String emoji,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? color : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 16,
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

  // CONSOLE 2: Planning Committee (Hidden Layer)
  Widget _buildPlanningCommitteeConsole() {
    return BlocBuilder<NeuralNetworkCubit, NeuralNetworkState>(
      builder: (context, state) {
        final isPhaseI = context.read<NeuralNetworkCubit>().isPhaseI;
        final input = [
          _isRainy ? 1 : 0,
          _hasHomework ? 1 : 0,
          _isWeekend ? 1 : 0,
        ];
        final activations = context
            .read<NeuralNetworkCubit>()
            .getHiddenActivations(input);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏛️', style: TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Text(
                    'Planning Committee',
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isPhaseI
                    ? 'The committee members are locked in Phase I (they\'re experts!)'
                    : 'Adjust how the committee members think',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 20),

              // Committee Member 1: Rain Detector
              _buildCommitteeMember(
                title: 'Rain Detector 🌧️',
                description: 'Specialized to detect rainy weather',
                isLocked: isPhaseI,
                color: const Color(0xFF3498DB),
                activations: activations['hidden1']!,
                activationSum: activations['hidden1Sum']!,
                weights: {
                  'Rainy': state.wRainyToHidden1,
                  'Homework': state.wHomeworkToHidden1,
                  'Weekend': state.wWeekendToHidden1,
                },
                bias: state.biasHidden1,
              ),

              const SizedBox(height: 16),

              // Committee Member 2: Homework Detector
              _buildCommitteeMember(
                title: 'Homework Detector 📚',
                description: 'Specialized to detect homework',
                isLocked: isPhaseI,
                color: const Color(0xFFE74C3C),
                activations: activations['hidden2']!,
                activationSum: activations['hidden2Sum']!,
                weights: {
                  'Rainy': state.wRainyToHidden2,
                  'Homework': state.wHomeworkToHidden2,
                  'Weekend': state.wWeekendToHidden2,
                },
                bias: state.biasHidden2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommitteeMember({
    required String title,
    required String description,
    required bool isLocked,
    required Color color,
    required double activations,
    required double activationSum,
    required Map<String, double> weights,
    required double bias,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🔒 Locked',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.fredoka(
              fontSize: 12,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 12),

          // Current activation display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Opinion:',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(activations * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Sum: ${activationSum.toStringAsFixed(2)}',
                      style: GoogleFonts.fredoka(fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 100,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: activations,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Weight display (read-only in Phase I)
          Text(
            'Weights:',
            style: GoogleFonts.fredoka(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeightDisplay('🌧️', weights['Rainy']!, color),
              _buildWeightDisplay('📚', weights['Homework']!, color),
              _buildWeightDisplay('🎉', weights['Weekend']!, color),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bias: ', style: GoogleFonts.fredoka(fontSize: 12)),
              Text(
                bias.toStringAsFixed(1),
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightDisplay(String emoji, double value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: GoogleFonts.fredoka(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // CONSOLE 3: Kid's Brain (Output Layer)
  Widget _buildKidsBrainConsole() {
    return BlocBuilder<NeuralNetworkCubit, NeuralNetworkState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Text(
                    'Kid\'s Brain (Final Decision)',
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'How much does the brain listen to each committee member?',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 20),

              // Priority Slider for Rain Detector
              _buildPrioritySlider(
                title: 'Rain Detector Priority 🌧️',
                description: 'How much to listen to the Rain Detector',
                value: state.wHidden1ToOutput,
                onChanged: (v) => context
                    .read<NeuralNetworkCubit>()
                    .setHiddenToOutputWeight(hiddenNeuron: 1, value: v),
                color: const Color(0xFF3498DB),
                min: -4,
                max: 4,
                constraint: 'Can be negative to ignore bad weather!',
              ),

              const SizedBox(height: 20),

              // Priority Slider for Homework Detector
              _buildPrioritySlider(
                title: 'Homework Detector Priority 📚',
                description: 'How much to listen to the Homework Detector',
                value: state.wHidden2ToOutput,
                onChanged: (v) => context
                    .read<NeuralNetworkCubit>()
                    .setHiddenToOutputWeight(hiddenNeuron: 2, value: v),
                color: const Color(0xFFE74C3C),
                min: -4,
                max: 4,
                constraint: 'Can be negative to ignore homework!',
              ),

              const SizedBox(height: 20),

              // Default Playfulness (Output Bias)
              _buildPrioritySlider(
                title: 'Default Playfulness 🎮',
                description: 'How much the brain wants to play by default',
                value: state.biasOutput,
                onChanged: (v) => context.read<NeuralNetworkCubit>().setBias(
                  layer: 'output',
                  value: v,
                ),
                color: const Color(0xFF9B59B6),
                min: -4,
                max: 4,
                constraint:
                    'Positive = wants to play, Negative = prefers staying in',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrioritySlider({
    required String title,
    required String description,
    required double value,
    required ValueChanged<double> onChanged,
    required Color color,
    required double min,
    required double max,
    required String constraint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.fredoka(
              fontSize: 12,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: ((max - min) * 10).round(),
                  activeColor: color,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    constraint,
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dataset Preview
  Widget _buildDatasetPreview() {
    return BlocBuilder<NeuralNetworkCubit, NeuralNetworkState>(
      builder: (context, state) {
        final db = context.read<NeuralNetworkCubit>().dataset;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 Test Results',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'See how well the committee matches the expected answers:',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 12),
              ...db.map((item) {
                final input = item['input'] as List<int>;
                final expectedAnswer = item['answer'] as int;
                final pred = context.read<NeuralNetworkCubit>().predict(input);
                final predictedAnswer = pred > 0.5 ? 1 : 0;
                final isCorrect = predictedAnswer == expectedAnswer;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCorrect ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['question'] as String,
                          style: GoogleFonts.fredoka(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Expected: ${expectedAnswer == 1 ? "Yes" : "No"}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isCorrect ? '✓' : '✗',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Got: ${predictedAnswer == 1 ? "Yes" : "No"} (${(pred * 100).toStringAsFixed(0)}%)',
                            style: GoogleFonts.fredoka(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
