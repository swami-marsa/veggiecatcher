# VeggieCatcher Game Architecture

This document outlines the architecture of the VeggieCatcher game after refactoring.

## Overview

The game has been refactored to follow a more modular architecture with clear separation of concerns. Each component has a single responsibility, making the code more maintainable and testable.

## Core Components

### Models

- **GameCircle**: Represents a vegetable or bomb that falls from the top of the screen.
- **CircleColor**: Enum representing different types of vegetables and their visual properties.
- **PowerUp**: Represents special items that provide bonuses when collected.

### Managers

- **GameState**: Main coordinator that manages the overall game state and connects other managers.
- **LevelManager**: Handles level progression, difficulty settings, and vegetable selection.
- **ScoreManager**: Manages score tracking, high scores, and persistence.
- **LifeManager**: Tracks player lives, missed vegetables, and related effects.
- **SoundManager**: Handles sound effects and background music.

### Constants

Game constants have been centralized in a `Constants` enum with nested enums for different categories:
- **Game**: Game mechanics constants like initial lives, speeds, etc.
- **UI**: UI-related constants like sizes, durations, etc.
- **UserDefaultsKeys**: Keys used for saving game state in UserDefaults.
- **Sounds**: Sound file names used throughout the app.

## File Organization

The code has been reorganized into the following structure:

```
Models/
  ├── Constants.swift       # Game constants and configuration values
  ├── GameTypes.swift       # Shared type definitions (CircleColor, PowerUpType)
  ├── GameCircle.swift      # Game circle and power-up models
  ├── GameState.swift       # Main game state coordinator
  ├── LevelManager.swift    # Level progression and difficulty management
  ├── ScoreManager.swift    # Score tracking and persistence
  ├── LifeManager.swift     # Lives and missed vegetable management
  └── SoundManager.swift    # Audio management
  
Views/
  ├── CircleGameArea.swift  # Main gameplay area view
  ├── GameView.swift        # Container for gameplay
  ├── HomeScreen.swift      # Main menu
  ├── SplashScreen.swift    # Splash screen
  ├── GameOverView.swift    # Game over overlay
  ├── LevelCompleteView.swift # Level completion overlay
  └── PauseMenuView.swift   # Pause menu
  
Extensions/
  └── ViewExtensions.swift  # SwiftUI view extensions
```

This modular approach ensures that each component has a single responsibility and can be tested in isolation.

## Data Flow

1. User interactions are captured by Views
2. Views communicate with GameState
3. GameState coordinates with specific managers:
   - Updates score via ScoreManager
   - Tracks lives via LifeManager
   - Manages level progression via LevelManager
   - Plays sounds via SoundManager

## Game Loop

The game loop occurs in the CircleGameArea view, which:
1. Spawns vegetables at regular intervals
2. Animates vegetables falling down the screen
3. Detects taps on vegetables
4. Removes vegetables when tapped or when they exit the screen
5. Updates game state accordingly

## State Management

Game state is managed using SwiftUI's `@Published` properties in an `ObservableObject` class. This ensures that views are automatically updated when the underlying data changes.

## Persistence

Game progress is saved using UserDefaults:
- High score
- Last played level
- Continuation score (for resuming games)
- Music settings

## Future Improvements

- Add unit tests for each manager
- Implement a tutorial for new players
- Add analytics for game balance adjustments
- Improve accessibility
- Performance optimizations for older devices 