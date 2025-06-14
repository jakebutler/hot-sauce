# Hot Sauce

A beautiful iOS app for tracking your daily steps and activity, inspired by Palm Springs mid-century modern design.

## Features

- Daily step count tracking
- 30-day step history visualization
- Detailed activity data including:
  - Steps
  - Distance
  - Calories burned
  - Active minutes
- Beautiful Palm Springs-inspired design
- Interactive charts
- Local data storage

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- HealthKit enabled device

## Setup

1. Clone the repository
2. Open `HotSauce.xcodeproj` in Xcode
3. Select your development team in the project settings
4. Build and run the app on your device (HealthKit requires a physical device)

## Usage

1. Launch the app
2. Grant HealthKit permissions when prompted
3. View your daily step count
4. Interact with the 30-day chart by dragging to see detailed data
5. Scroll through the detailed history table
6. Pull to refresh for the latest data

## Architecture

The app is built using:
- SwiftUI for the user interface
- MVVM architecture
- HealthKit for health data
- Swift Charts for data visualization

## License

This project is licensed under the MIT License - see the LICENSE file for details. 