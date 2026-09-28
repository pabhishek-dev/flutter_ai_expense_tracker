# AI Expense Tracker
 
Flutter expense assistant. You type a natural-language request; Gemini can add expenses or report category totals using tools, and data is stored locally in SQLite.

## Features

- Ask questions such as "add 250 for lunch" or "how much did I spend on food?"
- Tool calling: `add_expense` and `get_category_total`
- Local `expenses.db` via sqflite
- Firebase AI (Gemini) + Firebase App Check (Android debug provider)

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK `^3.12.2`).
2. Firebase is already wired (`lib/firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`). Use the `pilot-project-ai` project, or run `flutterfire configure` for your own.
3. From the repo root:

```bash
flutter pub get
flutter run