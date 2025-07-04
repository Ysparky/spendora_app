# Spendora

Spendora is a modern personal finance management app built with Flutter that helps users track expenses, create budgets, and gain valuable insights into their spending habits.

## Features

- 📊 Expense Tracking: Easily record and categorize your daily expenses
- 💰 Budget Management: Set and monitor budgets for different spending categories
- 📈 Spending Analytics: Visualize your spending patterns with intuitive charts
- 💳 Card Management: Keep track of your credit and debit cards
- 🏠 Dashboard: Get a quick overview of your financial status

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.0)
- Dart SDK (^3.0.0)
- iOS development tools (for iOS development)
- Android development tools (for Android development)
- Firebase project setup

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

3. Configure Firebase for your app:
```bash
flutterfire configure
```

4. Copy the generated `lib/firebase_options.dart` file to your project
   - Note: This file contains sensitive information and is not included in version control
   - A template file `lib/firebase_options.template.dart` is provided for reference

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Ysparky/spendora_app.git
cd spendora_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Firebase configuration:
   - Follow the Firebase Setup instructions above
   - Ensure `lib/firebase_options.dart` is properly configured

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart          # App entry point
├── theme.dart         # App theme configuration
├── util.dart          # Utility functions
└── app_assets.dart    # Asset constants
```

## Development

### Code Style

This project follows the official Dart style guide and uses `flutter_lints` for consistent code formatting. To format your code:

```bash
flutter format .
```

To analyze the code:

```bash
flutter analyze
```

### Assets

- Icons are stored in SVG format in `assets/icons/`
- Images are stored in `assets/images/`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All contributors who participate in this project
