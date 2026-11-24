# My Personal Organizer – Flutter App

A Flutter-based personal organizer that helps users manage notes, organize information, and remember important events with calendar reminders.

## Features

- **Add Notes:** Create notes with a title and description.
- **Edit Notes:** Update existing notes whenever needed.
- **Delete Notes:** Remove notes that are no longer required.
- **Search Notes:** Find notes using their titles or descriptions.
- **Favorite Notes:** Mark important notes as favorites.
- **Note Categories:** Organize notes into different categories.
- **Calendar:** View events using a monthly calendar.
- **Event Reminders:** Add events with specific dates and times and receive notifications.
- **Local Storage:** Save notes and events on the device.

## Technologies Used

- Flutter
- Dart
- SharedPreferences
- Table Calendar
- Flutter Local Notifications
- Timezone

## Project Structure

```text
lib/
├── main.dart
├── screens/
│   ├── add_note_screen.dart
│   ├── add_event_screen.dart
│   └── calendar_screen.dart
└── services/
    ├── note_storage.dart
    ├── event_storage.dart
    └── notification_service.dart
```

## How to Run the Project

1. Install Flutter SDK and Android Studio or VS Code.
2. Clone this repository:

```bash
git clone https://github.com/Sanika045/my-notes-flutter.git
```

3. Open the project folder:

```bash
cd my-notes-flutter
```

4. Install dependencies:

```bash
flutter pub get
```

5. Connect an Android phone or start an emulator.
6. Run the application:

```bash
flutter run
```

## Screenshots

![My Personal Organizer App Screenshots](screenshots/photos.png)

## Author

**Sanika Fendre**

GitHub: https://github.com/Sanika045