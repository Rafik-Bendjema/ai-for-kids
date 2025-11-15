import 'package:bloc/bloc.dart';
import 'dart:math';

class WeightsState {
  final double wRainy;
  final double wHomework;
  final double wWeekend;
  final double bias;

  const WeightsState({
    required this.wRainy,
    required this.wHomework,
    required this.wWeekend,
    required this.bias,
  });

  factory WeightsState.initial() =>
      const WeightsState(wRainy: 0.0, wHomework: 0.0, wWeekend: 0.0, bias: 0.0);

  WeightsState copyWith({
    double? wRainy,
    double? wHomework,
    double? wWeekend,
    double? bias,
  }) {
    return WeightsState(
      wRainy: wRainy ?? this.wRainy,
      wHomework: wHomework ?? this.wHomework,
      wWeekend: wWeekend ?? this.wWeekend,
      bias: bias ?? this.bias,
    );
  }

  @override
  String toString() {
    return 'WeightsState(wRainy: ${wRainy.toStringAsFixed(3)}, '
        'wHomework: ${wHomework.toStringAsFixed(3)}, '
        'wWeekend: ${wWeekend.toStringAsFixed(3)}, '
        'bias: ${bias.toStringAsFixed(3)})';
  }
}

class WeightsCubit extends Cubit<WeightsState> {
  WeightsCubit() : super(WeightsState.initial());

  // Static, hard-coded database of questions / inputs.
  // This replaces any online or learned dataset: the app simply
  // shows questions from this static DB and visualizes predictions
  // depending on the 3 weights and the bias.
  final List<Map<String, dynamic>> dataset = [
    // all 8 combinations
    {
      'question': 'It is rainy, I have homework, and it\'s the weekend. Should I play?',
      'input': [1, 1, 1]
    },
    {
      'question': 'It is rainy, I have homework, and it\'s not the weekend. Should I play?',
      'input': [1, 1, 0]
    },
    {
      'question': 'It is rainy, no homework, weekend. Should I play?',
      'input': [1, 0, 1]
    },
    {
      'question': 'It is rainy, no homework, not weekend. Should I play?',
      'input': [1, 0, 0]
    },
    {
      'question': 'Not rainy, I have homework, weekend. Should I play?',
      'input': [0, 1, 1]
    },
    {
      'question': 'Not rainy, I have homework, not weekend. Should I play?',
      'input': [0, 1, 0]
    },
    {
      'question': 'Not rainy, no homework, weekend. Should I play?',
      'input': [0, 0, 1]
    },
    {
      'question': 'Not rainy, no homework, not weekend. Should I play?',
      'input': [0, 0, 0]
    },
  ];

  // Predict using the current weights and bias (sigmoid).
  double predict(List<int> input) {
    final sum =
        state.wRainy * input[0] +
        state.wHomework * input[1] +
        state.wWeekend * input[2] +
        state.bias;
    return 1 / (1 + pow(e, -sum));
  }

  // Instead of training, expose setters so the UI can change weights/bias
  // directly (the child experiments with parameters).
  void setWeights({double? wRainy, double? wHomework, double? wWeekend}) {
    emit(
      state.copyWith(
        wRainy: wRainy ?? state.wRainy,
        wHomework: wHomework ?? state.wHomework,
        wWeekend: wWeekend ?? state.wWeekend,
      ),
    );
  }

  void setBias(double bias) {
    emit(state.copyWith(bias: bias));
  }

  void setAll({required double wRainy, required double wHomework, required double wWeekend, required double bias}) {
    emit(WeightsState(wRainy: wRainy, wHomework: wHomework, wWeekend: wWeekend, bias: bias));
  }

  void reset() {
    emit(WeightsState.initial());
  }
}
