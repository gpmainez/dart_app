# Dart Match & Checkout Engine

A Flutter application for scoring 501/301 darts matches, featuring an optimal checkout pathfinder and an AI opponent simulator based on real board geometry and error distributions.

---

## Overview

The application serves as both a match scorer and a training tool. Instead of relying on static lookup tables for checkouts, it utilizes a graph/state-space search algorithm to calculate valid finishes dynamically based on remaining darts and individual player target weights.

The domain logic is fully decoupled from the Flutter UI layer, allowing complete independent testing of game rules, scoring edge cases, and simulation models.

---

## Architecture & Design

The codebase follows Clean Architecture principles, separating core domain logic from UI presentation:

```text
lib/
├── engine/                # Domain logic (pure Dart, zero Flutter dependencies)
│   ├── checkout_calculator.dart  # PriorityQueue-based state search & Isolate cache
│   ├── match_manager.dart        # Match state machine, bust rules, leg/set tracker
│   └── models/
│       └── player.dart           # Player abstraction, Visit statistics, Bot simulation
├── ui/                    # Presentation layer (Flutter)
│   ├── screens/           # MatchSetupScreen, MatchScreen
│   └── widgets/           # DartPad, PlayerScoreCard
└── main.dart              # Application bootstrap and theme setup
```

---

## Core Capabilities

### 1. Checkout Pathfinding Engine
* **Algorithm:** PriorityQueue-based branch-and-bound state exploration (`SearchState`), finding the lowest-cost path to exactly zero ending on a double.
* **Concurrency:** Runs heavy path calculations in a background Dart Isolate (`compute`) to ensure UI responsiveness (60/120 FPS).
* **Deterministic Bounds:** Instant validation for impossible dart scores (e.g. 159, 163, 165, 168, 169, or > 170).
* **Adaptive Weighting:** Adjusts target priorities based on the player's historical hit and miss rates.

### 2. Physics-Based Bot Engine
* **Board Modeling:** Maps standard dartboard dimensions (trebles, doubles, bulls) to a polar coordinate system $(r, \theta)$.
* **Error Distribution:** Simulates throw variance using the Box-Muller transform for a 2D Gaussian distribution, where standard deviation $\sigma$ is scaled inversely to the bot's target 3-dart average.
* **Collision Detection:** Translates coordinates back into segment hits (Single, Double, Treble, Bull, Miss).

### 3. Match Management & Validation
* Tracks 3-dart averages, checkout percentages, 180s, 140s+, and 100s+.
* Strict enforcement of standard WDF/PDC rules (bust on $\le 1$ unless 0 on double).
* Single-throw and full-visit undo functionality with state recovery.
* Match configuration for customizable legs and sets format.

---

## Testing & Code Quality

The domain engine is backed by a suite of unit tests covering scoring edge cases and algorithm correctness:

```bash
# Static analysis
flutter analyze

# Execute test suite
flutter test
```

### Coverage Scope:
* Checkout calculation across boundary scores (170 Big Fish, 40, 50, impossible finishes).
* Turn lifecycle, bust triggers, and undo operations.
* Player statistics computation (3-dart average, double percentage).
* Coordinate transformation and polar angle sector evaluation.

---

## Getting Started

### Requirements
* Flutter SDK 3.x+
* Dart SDK 3.x+

### Setup
```bash
git clone https://github.com/gpmainez/dart_app.git
cd dart_app
flutter pub get
flutter run
```
