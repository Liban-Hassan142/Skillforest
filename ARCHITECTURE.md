# SkillForest Architecture

## Overview
SkillForest is a Flutter application that helps users track skill development through practice sessions and visual tree growth.

The app uses Flutter for its interface and SQLite for local data storage.

## Project Organization

- lib/main.dart: Application entry point
- lib/models/: Skill and practice session models
- lib/screens/: Application screens
- lib/services/database_helper.dart: Database operations
- lib/widgets/: Reusable interface components
- test/: Automated tests

## Application Screens

### Splash Screen
Displays the SkillForest introduction before opening the dashboard.

### Dashboard
Displays saved skills and provides access to skill management and progress information.

### Skill Form
Allows users to create and edit skills.

### Skill Details
Displays information about an individual skill and supports practice logging and progress tracking.

### History and Insights
Allows users to review their recorded practice activity.

## Data Storage

SkillForest uses the sqflite package to store application data locally.

The main data models are:

- Skill: Represents a skill being tracked.
- PracticeSession: Represents a recorded practice activity.

The DatabaseHelper service manages database operations, including saving skills, retrieving practice history, updating progress, and deleting skills.

## Application Flow

1. The user opens SkillForest.
2. The splash screen appears.
3. The dashboard displays saved skills.
4. The user creates or selects a skill.
5. The user records practice time and optional notes.
6. The application saves the session locally.
7. Skill progress and history reflect the saved activity.

## Dependencies

- Flutter and Dart
- sqflite
- path
- shared_preferences
- cupertino_icons

## Testing

The application was checked using Flutter's static analyzer and automated startup test.

Manual emulator testing confirmed that users can create, edit, and delete skills and record practice sessions.

## Limitations

Data is stored locally on the device. The application does not currently provide cloud synchronization or account-based backup.
