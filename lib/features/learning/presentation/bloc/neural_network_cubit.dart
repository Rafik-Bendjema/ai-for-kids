import 'package:bloc/bloc.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class NeuralNetworkState {
  // Input to Hidden Layer weights (3 inputs × 2 hidden neurons)
  final double wRainyToHidden1;
  final double wRainyToHidden2;
  final double wHomeworkToHidden1;
  final double wHomeworkToHidden2;
  final double wWeekendToHidden1;
  final double wWeekendToHidden2;
  
  // Hidden to Output weights (2 hidden neurons × 1 output)
  final double wHidden1ToOutput;
  final double wHidden2ToOutput;
  
  // Biases
  final double biasHidden1;
  final double biasHidden2;
  final double biasOutput;

  const NeuralNetworkState({
    required this.wRainyToHidden1,
    required this.wRainyToHidden2,
    required this.wHomeworkToHidden1,
    required this.wHomeworkToHidden2,
    required this.wWeekendToHidden1,
    required this.wWeekendToHidden2,
    required this.wHidden1ToOutput,
    required this.wHidden2ToOutput,
    required this.biasHidden1,
    required this.biasHidden2,
    required this.biasOutput,
  });

  factory NeuralNetworkState.initial() => const NeuralNetworkState(
        wRainyToHidden1: 0.0,
        wRainyToHidden2: 0.0,
        wHomeworkToHidden1: 0.0,
        wHomeworkToHidden2: 0.0,
        wWeekendToHidden1: 0.0,
        wWeekendToHidden2: 0.0,
        wHidden1ToOutput: 0.0,
        wHidden2ToOutput: 0.0,
        biasHidden1: 0.0,
        biasHidden2: 0.0,
        biasOutput: 0.0,
      );

  NeuralNetworkState copyWith({
    double? wRainyToHidden1,
    double? wRainyToHidden2,
    double? wHomeworkToHidden1,
    double? wHomeworkToHidden2,
    double? wWeekendToHidden1,
    double? wWeekendToHidden2,
    double? wHidden1ToOutput,
    double? wHidden2ToOutput,
    double? biasHidden1,
    double? biasHidden2,
    double? biasOutput,
  }) {
    return NeuralNetworkState(
      wRainyToHidden1: wRainyToHidden1 ?? this.wRainyToHidden1,
      wRainyToHidden2: wRainyToHidden2 ?? this.wRainyToHidden2,
      wHomeworkToHidden1: wHomeworkToHidden1 ?? this.wHomeworkToHidden1,
      wHomeworkToHidden2: wHomeworkToHidden2 ?? this.wHomeworkToHidden2,
      wWeekendToHidden1: wWeekendToHidden1 ?? this.wWeekendToHidden1,
      wWeekendToHidden2: wWeekendToHidden2 ?? this.wWeekendToHidden2,
      wHidden1ToOutput: wHidden1ToOutput ?? this.wHidden1ToOutput,
      wHidden2ToOutput: wHidden2ToOutput ?? this.wHidden2ToOutput,
      biasHidden1: biasHidden1 ?? this.biasHidden1,
      biasHidden2: biasHidden2 ?? this.biasHidden2,
      biasOutput: biasOutput ?? this.biasOutput,
    );
  }
}

class NeuralNetworkCubit extends Cubit<NeuralNetworkState> {
  NeuralNetworkCubit() : super(_createPhaseIInitialState()) {
    _loadDataset();
  }

  // Phase I: Locked hidden layer with specialized detectors
  // H1 = Rain Detector: Rainy=+3, Bias=-2
  // H2 = Homework Detector: Homework=+3, Bias=-2
  static NeuralNetworkState _createPhaseIInitialState() {
    return NeuralNetworkState(
      // H1: Rain Detector - specialized to detect rain
      wRainyToHidden1: 3.0,      // Strong positive for rain
      wHomeworkToHidden1: 0.0,   // Ignore homework
      wWeekendToHidden1: 0.0,    // Ignore weekend
      biasHidden1: -2.0,         // Bias threshold
      
      // H2: Homework Detector - specialized to detect homework
      wRainyToHidden2: 0.0,      // Ignore rain
      wHomeworkToHidden2: 3.0,   // Strong positive for homework
      wWeekendToHidden2: 0.0,    // Ignore weekend
      biasHidden2: -2.0,         // Bias threshold
      
      // Output layer - adjustable in Phase I
      wHidden1ToOutput: 0.0,
      wHidden2ToOutput: 0.0,
      biasOutput: 0.0,
    );
  }

  bool _isPhaseI = true; // Phase I: Hidden layer locked, only output adjustable

  bool get isPhaseI => _isPhaseI;

  void unlockPhaseII() {
    _isPhaseI = false;
    // Keep current state but allow all parameters to be adjusted
  }

  List<Map<String, dynamic>> _dataset = [];

  List<Map<String, dynamic>> get dataset => _dataset;

  Future<void> _loadDataset() async {
    try {
      final String data = await rootBundle.loadString('assets/data/dataset.csv');
      final List<String> lines = data.split('\n');
      
      _dataset = [];
      
      // Skip header line
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final parts = line.split(',');
        if (parts.length >= 4) {
          final rainy = int.parse(parts[0].trim());
          final homework = int.parse(parts[1].trim());
          final weekend = int.parse(parts[2].trim());
          final answer = int.parse(parts[3].trim());
          
          // Generate question text
          final rainyText = rainy == 1 ? 'It is rainy' : 'Not rainy';
          final homeworkText = homework == 1 ? 'I have homework' : 'no homework';
          final weekendText = weekend == 1 ? 'it\'s the weekend' : 'it\'s not the weekend';
          
          _dataset.add({
            'question': '$rainyText, $homeworkText, $weekendText. Should I play?',
            'input': [rainy, homework, weekend],
            'answer': answer,
          });
        }
      }
    } catch (e) {
      // Fallback to hardcoded dataset if CSV fails
      _dataset = [
        {
          'question': 'It is rainy, I have homework, and it\'s the weekend. Should I play?',
          'input': [1, 1, 1],
          'answer': 0,
        },
        {
          'question': 'It is rainy, I have homework, and it\'s not the weekend. Should I play?',
          'input': [1, 1, 0],
          'answer': 0,
        },
        {
          'question': 'It is rainy, no homework, weekend. Should I play?',
          'input': [1, 0, 1],
          'answer': 0,
        },
        {
          'question': 'It is rainy, no homework, not weekend. Should I play?',
          'input': [1, 0, 0],
          'answer': 0,
        },
        {
          'question': 'Not rainy, I have homework, weekend. Should I play?',
          'input': [0, 1, 1],
          'answer': 0,
        },
        {
          'question': 'Not rainy, I have homework, not weekend. Should I play?',
          'input': [0, 1, 0],
          'answer': 0,
        },
        {
          'question': 'Not rainy, no homework, weekend. Should I play?',
          'input': [0, 0, 1],
          'answer': 1,
        },
        {
          'question': 'Not rainy, no homework, not weekend. Should I play?',
          'input': [0, 0, 0],
          'answer': 1,
        },
      ];
    }
  }

  // Sigmoid activation function
  double _sigmoid(double x) {
    return 1 / (1 + pow(e, -x));
  }

  // Forward propagation through the network
  double predict(List<int> input) {
    final rainy = input[0].toDouble();
    final homework = input[1].toDouble();
    final weekend = input[2].toDouble();

    // Input to Hidden Layer
    final hidden1Sum = state.wRainyToHidden1 * rainy +
        state.wHomeworkToHidden1 * homework +
        state.wWeekendToHidden1 * weekend +
        state.biasHidden1;
    final hidden1 = _sigmoid(hidden1Sum);

    final hidden2Sum = state.wRainyToHidden2 * rainy +
        state.wHomeworkToHidden2 * homework +
        state.wWeekendToHidden2 * weekend +
        state.biasHidden2;
    final hidden2 = _sigmoid(hidden2Sum);

    // Hidden to Output Layer
    final outputSum = state.wHidden1ToOutput * hidden1 +
        state.wHidden2ToOutput * hidden2 +
        state.biasOutput;
    final output = _sigmoid(outputSum);

    return output;
  }

  // Calculate accuracy on the dataset
  double calculateAccuracy() {
    if (_dataset.isEmpty) return 0.0;
    
    int correct = 0;
    for (final item in _dataset) {
      final input = item['input'] as List<int>;
      final expectedAnswer = item['answer'] as int;
      final prediction = predict(input);
      final predictedAnswer = prediction > 0.5 ? 1 : 0;
      
      if (predictedAnswer == expectedAnswer) {
        correct++;
      }
    }
    
    return correct / _dataset.length;
  }

  // Setters for weights
  void setInputToHiddenWeight({
    String? inputType,
    int? hiddenNeuron,
    double? value,
  }) {
    if (_isPhaseI) {
      // Phase I: Hidden layer is locked, don't allow changes
      return;
    }
    
    if (inputType == 'rainy') {
      if (hiddenNeuron == 1) {
        emit(state.copyWith(wRainyToHidden1: value));
      } else if (hiddenNeuron == 2) {
        emit(state.copyWith(wRainyToHidden2: value));
      }
    } else if (inputType == 'homework') {
      if (hiddenNeuron == 1) {
        emit(state.copyWith(wHomeworkToHidden1: value));
      } else if (hiddenNeuron == 2) {
        emit(state.copyWith(wHomeworkToHidden2: value));
      }
    } else if (inputType == 'weekend') {
      if (hiddenNeuron == 1) {
        emit(state.copyWith(wWeekendToHidden1: value));
      } else if (hiddenNeuron == 2) {
        emit(state.copyWith(wWeekendToHidden2: value));
      }
    }
  }

  void setHiddenToOutputWeight({int? hiddenNeuron, double? value}) {
    if (hiddenNeuron == 1) {
      emit(state.copyWith(wHidden1ToOutput: value));
    } else if (hiddenNeuron == 2) {
      emit(state.copyWith(wHidden2ToOutput: value));
    }
  }

  void setBias({String? layer, int? neuron, double? value}) {
    if (layer == 'hidden') {
      if (_isPhaseI) {
        // Phase I: Hidden layer biases are locked
        return;
      }
      if (neuron == 1) {
        emit(state.copyWith(biasHidden1: value));
      } else if (neuron == 2) {
        emit(state.copyWith(biasHidden2: value));
      }
    } else if (layer == 'output') {
      // Output bias is always adjustable
      emit(state.copyWith(biasOutput: value));
    }
  }

  void reset() {
    _isPhaseI = true;
    emit(_createPhaseIInitialState());
  }

  // Get hidden neuron activations for visualization
  Map<String, double> getHiddenActivations(List<int> input) {
    final rainy = input[0].toDouble();
    final homework = input[1].toDouble();
    final weekend = input[2].toDouble();

    final hidden1Sum = state.wRainyToHidden1 * rainy +
        state.wHomeworkToHidden1 * homework +
        state.wWeekendToHidden1 * weekend +
        state.biasHidden1;
    final hidden1 = _sigmoid(hidden1Sum);

    final hidden2Sum = state.wRainyToHidden2 * rainy +
        state.wHomeworkToHidden2 * homework +
        state.wWeekendToHidden2 * weekend +
        state.biasHidden2;
    final hidden2 = _sigmoid(hidden2Sum);

    return {
      'hidden1': hidden1,
      'hidden2': hidden2,
      'hidden1Sum': hidden1Sum,
      'hidden2Sum': hidden2Sum,
    };
  }
}

