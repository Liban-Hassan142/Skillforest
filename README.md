# SkillForest

## About the App
SkillForest is a Flutter mobile application that helps users build skills by tracking their practice and progress. The app uses a tree-growth theme to make learning more motivating.

## Features
- Add, edit, and delete skills
- Record practice sessions with minutes and notes
- Track skill progress and tree growth
- Review practice history
- View History & Insights
- Save information locally using SQLite

## Technologies
- Flutter and Dart
- SQLite (sqflite)
- Shared Preferences
- Material Design

## Running the App
Install Flutter and Android development tools, then run:

    flutter pub get
    flutter run

## Building the APK
Run:

    flutter build apk --release

The APK is created at:
build/app/outputs/flutter-apk/app-release.apk

## Testing
- Flutter analysis completed with no issues
- Automated startup test passed
- Manually tested adding, editing, and deleting skills
- Manually tested practice logging and history

## Project Structure
- lib/models: Data models
- lib/screens: Application screens
- lib/services: Database operations
- lib/widgets: Reusable UI components
- test: Automated tests

## GitHub Repository
https://github.com/mcockerham26/skillforest
