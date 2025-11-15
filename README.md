# 🧠 Penguin's Brain: Neural Network Learning App for Kids

An interactive Flutter application designed to teach children about neural networks and machine learning through a playful "Playtime Planning Committee" metaphor. Kids learn how multi-layer perceptrons (MLPs) work by adjusting parameters to help a penguin decide whether to play outside.

## 📋 Table of Contents

- [Overview](#overview)
- [Educational Concept](#educational-concept)
- [Neural Network Architecture](#neural-network-architecture)
- [Learning Phases](#learning-phases)
- [User Interface](#user-interface)
- [Dataset](#dataset)
- [Technical Implementation](#technical-implementation)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [Usage Guide](#usage-guide)
- [Dependencies](#dependencies)
- [Educational Goals](#educational-goals)

## 🎯 Overview

This app transforms the abstract concept of neural networks into an accessible, visual learning experience. Instead of overwhelming children with 11 abstract parameters, the app uses a "Playtime Planning Committee" metaphor where:

- **Fact Cards** represent the input layer
- **Planning Committee Members** represent the hidden layer (specialized detectors)
- **Kid's Brain** represents the output layer (final decision maker)

The app starts in **Phase I** where 8 parameters are locked to pre-set values, allowing children to focus on learning just 3 key concepts: priority setting, negative weighting, and bias.

## 🎓 Educational Concept

### The Playtime Planning Committee Metaphor

The neural network is presented as a decision-making committee:

1. **📋 Fact Cards Console (Input Layer)**
   - Displays three binary inputs: Is it rainy? Do I have homework? Is it the weekend?
   - Children toggle these facts on/off to create different scenarios

2. **🏛️ Planning Committee Console (Hidden Layer)**
   - **Rain Detector (H1)**: A specialized committee member who only cares about rain
     - Pre-configured: Rainy=+3, Homework=0, Weekend=0, Bias=-2
     - Outputs a "concern level" about rain (0-100%)
   - **Homework Detector (H2)**: A specialized committee member who only cares about homework
     - Pre-configured: Rainy=0, Homework=+3, Weekend=0, Bias=-2
     - Outputs a "concern level" about homework (0-100%)
   - In Phase I, these are locked (experts with fixed opinions)
   - Shows real-time activation levels and internal calculations

3. **🧠 Kid's Brain Console (Output Layer)**
   - The final decision maker that listens to the committee
   - Three adjustable parameters in Phase I:
     - **Rain Detector Priority**: How much to listen to H1 (-4 to +4)
     - **Homework Detector Priority**: How much to listen to H2 (-4 to +4)
     - **Default Playfulness**: Base tendency to play (-4 to +4)

## 🏗️ Neural Network Architecture

### Network Structure

```
Input Layer (3 neurons) → Hidden Layer (2 neurons) → Output Layer (1 neuron)
   🌧️ Rainy                    🧠 Rain Detector (H1)        🎮 Play Decision
   📚 Homework                 🧠 Homework Detector (H2)
   🎉 Weekend
```

### Forward Propagation

1. **Input to Hidden Layer**:
   ```
   H1_sum = (wRainyToH1 × rainy) + (wHomeworkToH1 × homework) + 
            (wWeekendToH1 × weekend) + biasH1
   H1 = sigmoid(H1_sum)
   
   H2_sum = (wRainyToH2 × rainy) + (wHomeworkToH2 × homework) + 
            (wWeekendToH2 × weekend) + biasH2
   H2 = sigmoid(H2_sum)
   ```

2. **Hidden to Output Layer**:
   ```
   Output_sum = (wH1ToOutput × H1) + (wH2ToOutput × H2) + biasOutput
   Output = sigmoid(Output_sum)
   ```

3. **Sigmoid Activation Function**:
   ```
   sigmoid(x) = 1 / (1 + e^(-x))
   ```
   - Squashes values to range [0, 1]
   - Output represents probability of playing (0 = don't play, 1 = play)

### Parameters

**Total: 11 parameters**

- **Input → Hidden (6 weights)**:
  - `wRainyToHidden1`, `wRainyToHidden2`
  - `wHomeworkToHidden1`, `wHomeworkToHidden2`
  - `wWeekendToHidden1`, `wWeekendToHidden2`

- **Hidden → Output (2 weights)**:
  - `wHidden1ToOutput`, `wHidden2ToOutput`

- **Biases (3)**:
  - `biasHidden1`, `biasHidden2`, `biasOutput`

## 📚 Learning Phases

### Phase I: Learning Priority Settings 🎯

**Goal**: Understand how to set priorities and use negative weights

**Locked Parameters (8)**:
- All input-to-hidden weights are locked
- All hidden layer biases are locked
- H1 (Rain Detector): Rainy=+3, Bias=-2
- H2 (Homework Detector): Homework=+3, Bias=-2

**Adjustable Parameters (3)**:
- Rain Detector Priority (wHidden1ToOutput): -4 to +4
- Homework Detector Priority (wHidden2ToOutput): -4 to +4
- Default Playfulness (biasOutput): -4 to +4

**Learning Objectives**:
- Understand that negative weights mean "ignore" or "oppose"
- Learn to set priorities between different concerns
- See how bias affects default behavior
- Match predictions to expected answers in the dataset

### Phase II: Advanced Tuning ⚙️

**Goal**: Fine-tune all parameters for optimal performance

**All Parameters Adjustable (11)**:
- Unlock hidden layer weights and biases
- Full control over network architecture
- Advanced optimization and experimentation

## 🖥️ User Interface

### Main Screen Components

1. **Phase Indicator**
   - Shows current learning phase (Phase I or Phase II)
   - Color-coded badge (blue for Phase I, green for Phase II)

2. **Accuracy Score**
   - Real-time accuracy calculation based on dataset
   - Color-coded feedback:
     - 🟢 Green (>70%): Excellent
     - 🟠 Orange (40-70%): Good progress
     - 🔴 Red (<40%): Needs adjustment

3. **Three Interactive Consoles**:
   - **Fact Cards**: Input selection
   - **Planning Committee**: Hidden layer visualization
   - **Kid's Brain**: Output layer controls

4. **Test Results Section**
   - Shows all 8 dataset scenarios
   - Expected vs predicted answers
   - Visual indicators (✓/✗) for correct/incorrect predictions
   - Percentage confidence for each prediction

5. **Ask the Committee Button**
   - Triggers prediction for current input selection
   - Animated brain response with decision

### Visual Features

- **Real-time Activation Display**: Shows what each committee member "thinks" (0-100%)
- **Weight Visualization**: Displays current weights with emojis
- **Progress Bars**: Visual representation of neuron activations
- **Locked Indicators**: Clear badges showing which parameters are locked
- **Constraint Hints**: Educational tooltips explaining what values mean

## 📊 Dataset

### Structure

The dataset is stored in `assets/data/dataset.csv` with the following format:

```csv
rainy,homework,weekend,answer
1,1,1,0
1,1,0,0
1,0,1,0
1,0,0,0
0,1,1,0
0,1,0,0
0,0,1,1
0,0,0,1
```

### Logic

The dataset contains all 8 possible combinations of the three binary inputs with logical answers:

- **Rainy = Don't Play**: If it's raining, don't play (regardless of other factors)
- **Homework = Don't Play**: If there's homework, don't play (unless it's not rainy)
- **Perfect Conditions = Play**: Not rainy + No homework = Play (regardless of weekend)

**Complete Truth Table**:

| Rainy | Homework | Weekend | Answer | Logic |
|-------|----------|--------|--------|-------|
| 1 | 1 | 1 | 0 | Rainy → Don't play |
| 1 | 1 | 0 | 0 | Rainy → Don't play |
| 1 | 0 | 1 | 0 | Rainy → Don't play |
| 1 | 0 | 0 | 0 | Rainy → Don't play |
| 0 | 1 | 1 | 0 | Homework → Don't play |
| 0 | 1 | 0 | 0 | Homework → Don't play |
| 0 | 0 | 1 | 1 | Perfect conditions → Play |
| 0 | 0 | 0 | 1 | Perfect conditions → Play |

## 🔧 Technical Implementation

### State Management

Uses **BLoC (Business Logic Component)** pattern with `flutter_bloc`:

- **NeuralNetworkCubit**: Manages network state and calculations
- **NeuralNetworkState**: Holds all 11 parameters
- **Reactive UI**: Updates automatically when parameters change

### Key Files

1. **`lib/features/learning/presentation/bloc/neural_network_cubit.dart`**:
   - Network state management
   - Forward propagation logic
   - Dataset loading from CSV
   - Accuracy calculation
   - Phase I/II control

2. **`lib/features/learning/presentation/widgets/free_play_screen.dart`**:
   - Main UI implementation
   - Three console widgets
   - Interactive sliders and controls
   - Real-time visualization

3. **`assets/data/dataset.csv`**:
   - Training/test dataset
   - Loaded at runtime

### Core Functions

**Forward Propagation**:
```dart
double predict(List<int> input) {
  // Calculate hidden layer activations
  final hidden1 = sigmoid(weightedSum1);
  final hidden2 = sigmoid(weightedSum2);
  
  // Calculate output
  final output = sigmoid(hidden1 * w1 + hidden2 * w2 + bias);
  return output;
}
```

**Accuracy Calculation**:
```dart
double calculateAccuracy() {
  int correct = 0;
  for (final item in dataset) {
    final prediction = predict(item['input']);
    final expected = item['answer'];
    if ((prediction > 0.5 ? 1 : 0) == expected) {
      correct++;
    }
  }
  return correct / dataset.length;
}
```

## 📁 Project Structure

```
kids/
├── lib/
│   ├── main.dart
│   └── features/
│       ├── intro/
│       │   └── presentation/
│       │       └── screens/
│       │           └── intro_screen.dart
│       ├── landing/
│       │   └── presntation/
│       │       └── screens/
│       │           └── landing_screen.dart
│       ├── learning/
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── neural_network_cubit.dart  # Main network logic
│       │       │   └── weights_cubit.dart         # Legacy (simple perceptron)
│       │       ├── screens/
│       │       │   └── learning_game_screen.dart
│       │       └── widgets/
│       │           └── free_play_screen.dart      # Main UI
│       └── shared/
│           └── widgets/
├── assets/
│   ├── data/
│   │   └── dataset.csv                            # Training dataset
│   ├── gif/
│   │   └── gif1.gif ... gif6.gif                  # Intro animations
│   └── images/
│       └── brain_landing.png
├── pubspec.yaml                                    # Dependencies
└── README.md
```

## 🚀 Setup & Installation

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator / Physical device

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd kids
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify assets are configured**:
   - Check `pubspec.yaml` includes:
     ```yaml
     assets:
       - assets/images/
       - assets/gif/
       - assets/data/
     ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### Building for Production

**Android**:
```bash
flutter build apk --release
```

**iOS**:
```bash
flutter build ios --release
```

## 📖 Usage Guide

### Getting Started

1. **Launch the app**: The intro screen appears with penguin animations
2. **Navigate through intro**: Swipe or tap "Next" to learn about the brain
3. **Enter Free Play Mode**: After intro, you'll see the Planning Committee interface

### Phase I: Learning Mode

1. **Set Facts**: Toggle the three fact cards (Rainy, Homework, Weekend)
2. **Observe Committee**: Watch how Rain Detector and Homework Detector respond
   - Their activations update in real-time
   - See their "opinions" as percentages
3. **Adjust Priorities**: Use the three sliders in Kid's Brain console:
   - **Rain Detector Priority**: Set negative to ignore rain concerns
   - **Homework Detector Priority**: Set negative to ignore homework concerns
   - **Default Playfulness**: Set positive for optimistic, negative for cautious
4. **Check Accuracy**: Watch the accuracy score change as you adjust
5. **Test Scenarios**: Try different fact combinations and see predictions
6. **Match Dataset**: Goal is to get 100% accuracy matching expected answers

### Understanding the Controls

**Priority Sliders**:
- **Positive values** (+1 to +4): "Listen more to this detector"
- **Negative values** (-1 to -4): "Ignore or oppose this detector"
- **Zero**: "Don't consider this detector"

**Default Playfulness**:
- **Positive**: Base tendency to want to play
- **Negative**: Base tendency to stay inside
- **Zero**: Neutral starting point

### Tips for Success

1. **Start with negatives**: Set Rain and Homework priorities to negative values (around -2 to -3)
2. **Adjust playfulness**: Set Default Playfulness to positive (around +1 to +2)
3. **Watch the test results**: Green checkmarks mean correct predictions
4. **Iterate**: Small adjustments can make big differences

## 📦 Dependencies

### Main Dependencies

- **flutter_bloc (^8.1.4)**: State management
- **google_fonts (^6.2.1)**: Custom typography (Fredoka font)
- **lottie (^3.1.2)**: Animation support
- **gif (^2.3.0)**: GIF animation support

### Development Dependencies

- **flutter_test**: Testing framework
- **flutter_lints (^5.0.0)**: Code quality and linting

## 🎓 Educational Goals

### Learning Objectives

1. **Understand Neural Networks**:
   - Learn that neural networks are decision-making systems
   - See how inputs flow through layers to produce outputs
   - Understand the concept of weighted connections

2. **Grasp Multi-Layer Perceptrons**:
   - Understand why hidden layers exist
   - See how specialized detectors work
   - Learn how layers combine information

3. **Master Key Concepts**:
   - **Weights**: Strength of connections
   - **Biases**: Default tendencies
   - **Activation Functions**: How neurons "fire"
   - **Priority Setting**: How to combine multiple inputs

4. **Develop Intuition**:
   - Negative weights mean "oppose" or "ignore"
   - Positive weights mean "support" or "listen"
   - Bias sets default behavior
   - Multiple inputs combine to make decisions

### Age Appropriateness

- **Target Age**: 8-14 years
- **Prerequisites**: Basic understanding of yes/no questions
- **No coding required**: Pure visual and interactive learning

## 🔍 Technical Details

### Activation Function

Uses **sigmoid activation** for all layers:
- Smooth, differentiable function
- Outputs values between 0 and 1
- Interpretable as probabilities
- Classic choice for binary classification

### Initialization

**Phase I Initial State**:
- Hidden layer weights: Specialized detectors (Rain=+3, Homework=+3)
- Hidden layer biases: -2 (threshold for activation)
- Output layer: All zeros (blank slate for learning)

### Performance

- **Real-time updates**: All calculations happen instantly
- **Smooth animations**: 60 FPS UI updates
- **Efficient state management**: Only rebuilds necessary widgets
- **CSV loading**: Async dataset loading with fallback

## 🐛 Troubleshooting

### Common Issues

1. **CSV not loading**:
   - Check `assets/data/dataset.csv` exists
   - Verify `pubspec.yaml` includes `assets/data/`
   - Run `flutter clean` and `flutter pub get`

2. **Accuracy stuck at 0%**:
   - Check that output weights are not all zero
   - Try setting priorities to non-zero values
   - Verify dataset is loaded correctly

3. **UI not updating**:
   - Ensure BLoC provider is set up correctly
   - Check that state is being emitted
   - Verify widget is wrapped in BlocBuilder



## 📝 License

[Specify your license here]

## 👥 Contributors

BENDJEMA AHMED RAFIK



**Made with ❤️ for teaching kids about AI and neural networks**
