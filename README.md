# Patente B (Flutter · iOS + Android)

Premium bilingual Italian Category B driving-theory app. **100% offline**: no API, no
webviews, no remote images, no remote database. Every question ships inside the app and is
loaded into a local SQLite database on first launch.

## Offline architecture

```
assets/data/seed.json        ← bundled content (25 chapters · 7,139 questions · vocabulary)
        │  first launch only
        ▼
SQLite (sqflite, on device)  ← chapters, questions, vocabulary, attempts,
                               chapter_progress, exams, bookmarks
        │
        ▼
AppState (ChangeNotifier)    ← readiness, accuracy, streak, weak topics, mistakes
        │
        ▼
Screens (Home · Fast Track · Quiz · Chapters · Exam · Stats · Settings)
```

- `lib/data/local_store.dart` — schema, seeding, queries, progress aggregation.
- `lib/data/app_state.dart` — single source of truth; records answers/exams locally.
- `assets/data/seed.json` — generated from `src/data/private/bank.json` by
  `scripts/export_flutter_seed.py`.
- SQL verified against the real seed with `scripts/verify_flutter_db.py`.

No `NetworkImage`, `http`, or `dio` anywhere. Road-sign visuals are drawn with `CustomPainter`
(`lib/widgets/sign_art.dart`), so the app needs **zero** image downloads.

## Modules

- Intelligent Home Dashboard (readiness ring, streak, accuracy, next action, local badge)
- **Fast Track** — 2-day intensive plan + essential Italian vocabulary (from DB)
- Bilingual quiz (IT + EN, hints, chapter-aware sign artwork)
- 25 official chapters, each with per-chapter accuracy and progress
- Exam simulation: 30 questions · 20:00 countdown · max 3 errors · results saved
- Mistakes + spaced revision (only real wrong answers from your DB)
- Advanced statistics: 7-day trend, weak chapters, readiness estimate
- Settings: database stats, offline info, reset progress (with confirmation)

## Run

```bash
cd "j:\ITALIAN LICENSE\patente_b"
flutter pub get
flutter run                 # Android device / emulator
# macOS only:
flutter run -d ios
```

### Build

```bash
flutter build apk --release          # Android
flutter build appbundle --release    # Play Store
flutter build ipa --release          # iOS (requires macOS + Xcode)
```

## Notes

- App is portrait-locked for both platforms.
- Bundle identifier: `com.patenteb.patenteb`.
- Version code `1011319819` (Android caps at 2,100,000,000).
- Regenerate the seed after editing the question bank:
  `python scripts/export_flutter_seed.py`
- Launcher icon sources live in `assets/icon/` (generate sizes with
  `flutter_launcher_icons` if desired).
