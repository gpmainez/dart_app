# 🎯 Dart Scorer & Checkout Engine

A modern Flutter application designed for darts players, featuring an **intelligent checkout calculator** and a **physics-inspired AI bot engine**.

![Flutter CI](https://github.com/your-username/dart_app/actions/workflows/flutter.yml/badge.svg)
![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## 📌 Project Overview

This project was built to provide a robust, responsive scoreboard and training companion for darts enthusiasts. Unlike standard counter apps, this project features:
1. **Dynamic State-Space Search for Checkouts:** Finding optimal finishing combinations based on darts left and user target weights.
2. **Polar-Coordinate Gaussian AI Bot:** An AI opponent whose throws are calculated using 2D normal distributions (Box-Muller transform) scaled to a target 3-dart average.
3. **Clean Architecture & Decoupled Domain Engine:** Pure Dart domain logic separate from the Flutter UI layer, allowing 100% unit test coverage of game mechanics.

---

## 🚀 Key Features & Engineering Highlights

### 1. Optimal Checkout Engine (`Dijkstra / Branch-and-Bound`)
* **State-Space Exploration:** Calculates the best path to 0 ending on a double (`SearchState`).
* **Adaptive Weighting:** Learns player preferences over time (`rewardTarget` / `penalizeTarget`).
* **Isolate Acceleration:** Utilizes Dart's `compute` to run complex combinatorial calculations off the main UI thread.
* **Deterministic Boundary Validation:** Instant rejections for impossible checkouts (e.g. 159, 163, 165, 168, 169 or > 170).

### 2. Gaussian Simulation Engine (AI Bot)
* **Dartboard Polar Mapping:** Converts board millimetric dimensions into polar coordinates `(r, θ)`.
* **Box-Muller Normal Distribution:** Simulates human error spread around the intended target with variance ($\sigma = \frac{1000}{\text{botAverage}}$).
* **Sector Collision Detection:** Evaluates hits across singles, doubles, trebles, outer bull, and bullseye.

### 3. Clean Architecture
```text
lib/
├── engine/                # Pure Dart domain logic (no UI dependencies)
│   ├── checkout_calculator.dart  # PriorityQueue search & Isolate cache
│   ├── match_manager.dart        # Game loop, bust rules, leg/set tracker
│   └── models/
│       └── player.dart           # Player abstraction, Visit model, Bot simulation
├── ui/                    # Flutter Presentation Layer
│   ├── screens/           # MatchSetupScreen, MatchScreen
│   └── widgets/           # DartPad, PlayerScoreCard
└── main.dart              # Application entrypoint
```

---

## 🧪 Testing & Code Quality

The engine is covered by comprehensive unit tests verifying rules, edge cases, and board mathematics:
```bash
# Run static analysis
flutter analyze

# Run unit tests
flutter test
```

### Tested Scenarios:
- ✅ Big Fish checkout (170 points $\rightarrow$ `T20 -> T20 -> Bullseye`).
- ✅ Single-dart finishes (`D20`, `Bullseye`).
- ✅ Impossible score rejections (169, 168, 165, 163, 159).
- ✅ Bust conditions (reducing score to 1 or $<0$).
- ✅ Match lifecycle (undo history, turn finalization, leg/set progression).

---

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (3.x or later)
- Dart SDK (3.x or later)

### Installation
```bash
# Clone the repository
git clone https://github.com/your-username/dart_app.git

# Navigate to the project directory
cd dart_app

# Fetch dependencies
flutter pub get

# Run the app
flutter run
```
