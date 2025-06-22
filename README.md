# Hydrify - Flutter Water Reminder App

A Flutter application that reminds and notifies you to drink water. This app aims to keep users hydrated and healthy by suggesting daily water intake goals and tracking consumption.

## Features

- **Daily Water Goal Setting**: Set and customize your daily water intake goals
- **Water Consumption Tracking**: Log your water intake throughout the day
- **Smart Notifications**: Customizable reminders to drink water
- **History & Analytics**: View your drinking history and track progress
- **MVVM Architecture**: Clean, maintainable code structure
- **Beautiful UI**: Modern, intuitive user interface

## Architecture

This app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures and business logic
- **Views**: UI components and screens
- **ViewModels**: Business logic and state management
- **Services**: Database, notifications, and preferences management

## Getting Started

1. Make sure Flutter is installed on your system
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Dependencies

- `provider`: State management
- `sqflite`: Local database storage
- `flutter_local_notifications`: Push notifications
- `shared_preferences`: User preferences storage
- `fl_chart`: Charts and graphs
- `intl`: Internationalization and date formatting
- `permission_handler`: Handle device permissions

## Project Structure

```
lib/
├── models/           # Data models
├── views/            # UI screens
├── viewmodels/       # Business logic
├── services/         # External services
├── utils/            # Utilities and helpers
├── widgets/          # Reusable UI components
└── main.dart         # App entry point
```

## Features Overview

### Home Screen
- Daily progress tracking
- Quick water intake buttons
- Motivational messages
- Today's intake history

### History Screen
- Weekly intake charts
- Historical data viewing
- Progress insights
- Detailed statistics

### Profile Screen
- Personal information management
- Daily goal customization
- Notification settings
- Health metrics

## Contributing

Feel free to contribute to this project by submitting issues or pull requests.

## License

This project is licensed under the MIT License.
