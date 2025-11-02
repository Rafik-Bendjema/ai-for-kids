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

  double predict(List<int> input) {
    final sum =
        state.wRainy * input[0] +
        state.wHomework * input[1] +
        state.wWeekend * input[2] +
        state.bias;
    return 1 / (1 + pow(e, -sum));
  }

  void learn(List<int> input, int target, {double learningRate = 0.2}) {
    state.toString();

    final prediction = predict(input);
    final error = target - prediction;
    emit(
      state.copyWith(
        wRainy: state.wRainy + learningRate * error * input[0],
        wHomework: state.wHomework + learningRate * error * input[1],
        wWeekend: state.wWeekend + learningRate * error * input[2],
        bias: state.bias + learningRate * error,
      ),
    );
  }

  void reset() {
    emit(WeightsState.initial());
  }
}
