# QR Generator

An offline-first Flutter application for creating static QR codes locally on
Android and iOS.

## Features

- Generate QR codes from URLs or any text without a network connection.
- Customize foreground/background colors, error correction, size, and margin.
- Save PNG files locally and share them with native platform sharing.
- Copy input content and keep a local generation history.
- Reopen or delete history entries and clear all history.
- Persist history and light/dark theme preference with SharedPreferences.

## Run

```bash
flutter pub get
flutter run
```

QR generation uses `qr_flutter` directly in Dart. No backend, QR API, cloud
service, analytics, or remote resource is used.
