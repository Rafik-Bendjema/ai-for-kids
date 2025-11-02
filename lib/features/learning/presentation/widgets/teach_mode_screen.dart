import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'weight_meter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids/features/learning/presentation/bloc/weights_cubit.dart';

class TeachModeScreen extends StatefulWidget {
  final void Function(bool rainy, bool homework, bool weekend, bool kidSaysPlay)
  onConfirm;
  final VoidCallback onDone;
  final AnimationController weightAnimationController;

  const TeachModeScreen({
    super.key,
    required this.onConfirm,
    required this.onDone,
    required this.weightAnimationController,
  });

  @override
  State<TeachModeScreen> createState() => _TeachModeScreenState();
}

class _TeachModeScreenState extends State<TeachModeScreen>
    with TickerProviderStateMixin {
  bool _isRainy = false;
  bool _hasHomework = false;
  bool _isWeekend = false;
  bool _kidSaysPlay = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Teach Penguin\'s Brain',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Set a scenario, tell the brain if we should play,\nand it will learn!',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                color: const Color(0xFF7F8C8D),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Current weights
            Container(
              padding: const EdgeInsets.all(16),
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
                    'Current Weights',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<WeightsCubit, WeightsState>(
                    builder: (context, state) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeightMeter(
                            label: 'Rainy',
                            value: state.wRainy,
                            color: const Color(0xFF3498DB),
                            animationController:
                                widget.weightAnimationController,
                          ),
                          WeightMeter(
                            label: 'Homework',
                            value: state.wHomework,
                            color: const Color(0xFFE74C3C),
                            animationController:
                                widget.weightAnimationController,
                          ),
                          WeightMeter(
                            label: 'Weekend',
                            value: state.wWeekend,
                            color: const Color(0xFF2ECC71),
                            animationController:
                                widget.weightAnimationController,
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
                        animationController: widget.weightAnimationController,
                        isBias: true,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scenario builder
            _buildToggleCard(
              title: 'Is it rainy?',
              value: _isRainy,
              onChanged: (v) => setState(() => _isRainy = v),
              emoji: '🌧️',
              color: const Color(0xFF3498DB),
            ),
            const SizedBox(height: 12),
            _buildToggleCard(
              title: 'Do I have homework?',
              value: _hasHomework,
              onChanged: (v) => setState(() => _hasHomework = v),
              emoji: '📚',
              color: const Color(0xFFE74C3C),
            ),
            const SizedBox(height: 12),
            _buildToggleCard(
              title: 'Is it the weekend?',
              value: _isWeekend,
              onChanged: (v) => setState(() => _isWeekend = v),
              emoji: '🎉',
              color: const Color(0xFF2ECC71),
            ),

            const SizedBox(height: 20),

            // Kid's decision
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF6C5CE7), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🐧', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Should we play outside?',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Switch(
                    value: _kidSaysPlay,
                    onChanged: (v) => setState(() => _kidSaysPlay = v),
                    activeColor: const Color(0xFF6C5CE7),
                  ),
                  Text(
                    _kidSaysPlay ? 'YES' : 'NO',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6C5CE7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onDone,
                  child: Text(
                    'Done',
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(
                      _isRainy,
                      _hasHomework,
                      _isWeekend,
                      _kidSaysPlay,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Teach Brain',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required bool value,
    required void Function(bool) onChanged,
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
