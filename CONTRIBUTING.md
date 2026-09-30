# Contributing to FlowLedger

Thanks for helping! Bug reports, translation fixes and pull requests are all welcome.

## Reporting bugs

Open an issue with the FlowLedger version, your Windows version, what you did, what you expected and what happened. **Never attach your real database or reports** — they contain client and financial data. If a sample is needed, create one with made-up data.

## Development setup

FlowLedger is a Flutter desktop app (Dart, Material 3) with a local SQLite database (`sqflite` + `sqflite_common_ffi`).

| Tool | Version |
| --- | --- |
| Flutter | **3.44.2 stable** (Dart 3.12.2) — the lockfile requires it |
| Windows build | Visual Studio / Build Tools with *Desktop development with C++*, CMake, Windows SDK |

```powershell
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter analyze
flutter test
flutter run -d windows
flutter build windows --release   # output: build/windows/x64/runner/Release/
```

Close any running `flowledger.exe` before building, otherwise the linker cannot overwrite it (`LNK1104`).

On Linux, `setup.sh` installs the pinned Flutter SDK for analysis and tests only (it needs `git curl unzip xz tar` and `libsqlite3`). The repository contains only the Windows runner; Linux, macOS, web and mobile builds are not supported yet.

## Project layout

```text
lib/app/           App widget and controllers (theme, language, currency)
lib/core/          Theme, colours, formatting helpers
lib/l10n/          ARB translation files and generated localizations
lib/models/        Data models (one class per table, plus view models)
lib/repositories/  SQL queries and business rules
lib/screens/       Screens
lib/services/      Database helper (migrations, backup/restore), report export
lib/widgets/       Shared widgets; client/, works/ and revisions/ hold
                   widgets used by one screen or feature
test/              Unit, migration and widget tests (temp-file SQLite via ffi)
windows/           Windows runner
```

## Rules that keep user data safe

- **Schema changes need a migration.** Add `_createVersionN` in `lib/services/database_helper.dart`, bump `databaseVersion`, and keep it re-runnable (`IF NOT EXISTS`, check columns before `ALTER TABLE`). An older app build may downgrade the version number while leaving new tables in place.
- Add a test that seeds a database at the previous version, migrates it and checks that existing data is unchanged (see `test/revision_migration_test.dart`).
- Never delete rows physically; use `deleted_at`.
- Revision records (versions and feedback) must never change amounts, payments or work status.
- Tests use made-up data only.

## Translations

User-facing text lives in `lib/l10n/app_<lang>.arb` (`en` is the template).

1. Add or change the key in `app_en.arb` (with `@key` placeholder metadata if needed) and in `app_tr.arb`, `app_de.arb`, `app_ru.arb`.
2. Run `flutter gen-l10n` and commit the generated `app_localizations*.dart` files — CI fails if they are out of date.
3. Russian plurals need `one`, `few`, `many` and `other` forms.

To add a new language, create `app_<code>.arb` with every key, add the language to `lib/l10n/language_options.dart`, and run the tests.

Improvements to the German and Russian texts are especially welcome: they have not been reviewed by native speakers yet.

## Before opening a pull request

```powershell
dart format lib test
flutter analyze
flutter test
```

CI runs the same checks on every pull request and builds the Windows release. Keep pull requests small and focused, and describe what you tested.

## Releases

Maintainers tag `vX.Y.Z` on `main`. CI builds `FlowLedger-windows-x64.zip`, refuses to package any database file, and attaches the zip to a **draft** GitHub release that is published by hand after a manual check on Windows.

## License

By contributing you agree that your contributions are licensed under the [GPL-3.0](LICENSE), like the rest of the project.
