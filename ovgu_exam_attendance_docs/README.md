# OVGU Exam Attendance System Documentation

This folder contains documentation for the OVGU exam invigilation attendance app. The **MVP** is intentionally minimal; deeper features described across the package are either scoped to MVP or called out as **post-MVP** improvements.

## MVP scope (agreed product slice)

The first shippable product is:

1. **Import** a **CSV file on the device** listing **participants** for the exam (required columns at minimum: matriculation number and full name).
2. **Mark students present** during the exam using **ID card scanning** (on-device OCR → match the **participant list**) **or manual search** (same confirmation rules). Manual path must work if scanning fails.
3. **During the session**, the app shows **how many are present** and **how many are not yet marked** (total minus present). The UI does not label anyone “absent” until export.
4. **Export** via an explicit control: write a **CSV** where each **imported participant row** has **`present`** or **`absent`**. **`absent` is assigned only at export time**: any student without a confirmed present record at that moment is exported as absent.

**MVP:** no stored **timestamps** on participants or attendance (no `created_at`, `marked_at`, etc.); export may include **`method`** (`scan` / `manual`) for present rows only. Timing fields can be added later.

Everything runs **offline**; no cloud APIs or cloud OCR.

Post-MVP enhancements (sessions with metadata, full participant review screens, audit trails, encryption hardening, corrections, and so on) are documented in [11_future_improvements.md](11_future_improvements.md) and called out in individual documents.

**Implemented CSV validation (headers, empty file, row count):** see [CSV import validation (implemented)](04_data_model_design.md#csv-import-validation-implemented) in [04_data_model_design.md](04_data_model_design.md).

## Document Index

1. [01_problem_statement.md](01_problem_statement.md)
2. [02_product_requirements_document.md](02_product_requirements_document.md)
3. [03_system_architecture_and_design.md](03_system_architecture_and_design.md)
4. [04_data_model_design.md](04_data_model_design.md)
5. [05_ux_ui_design_specification.md](05_ux_ui_design_specification.md)
6. [06_ocr_and_scanning_strategy.md](06_ocr_and_scanning_strategy.md)
7. [07_security_and_privacy_design.md](07_security_and_privacy_design.md)
8. [08_testing_strategy.md](08_testing_strategy.md)
9. [09_deployment_and_distribution_plan.md](09_deployment_and_distribution_plan.md)
10. [10_risks_and_mitigations.md](10_risks_and_mitigations.md)
11. [11_future_improvements.md](11_future_improvements.md)
12. [12_phased_development_roadmap.md](12_phased_development_roadmap.md)

## Design Principles

- **MVP first:** smallest flow that works in the exam hall; extend later.
- Reliability under real exam conditions over feature breadth.
- Offline operation for all core workflows.
- Privacy by design and data minimization; stronger hardening can follow MVP.
- Manual fallback must always be available when scanning fails.

## Recommended Implementation Profile

- Platform: Flutter, Android-first, with iOS support as a later extension.
- OCR: On-device OCR only, with no cloud services and no external APIs.
- Local persistence: SQLite (or equivalent) in app-private storage; **encryption at rest post-MVP** unless governance requires it earlier.
- Distribution: Institution-controlled APK deployment on approved exam devices.

## SQLite vs Postgres (how local storage works here)

If you are used to **Postgres** on a server, local **SQLite** in a mobile app behaves differently:

| Postgres (typical web stack) | SQLite in this Flutter app |
|-------------------------------|----------------------------|
| Server at a host/port; tools like `psql` or a GUI connect over the network | **Single file** on the device/emulator, inside the app’s **private storage** — not in this git repo |
| One shared dev database | Each install (emulator, phone) has its **own** file |
| You browse tables anytime | You **copy the file out** or use `adb` / Simulator paths, then open with `sqlite3` or [DB Browser for SQLite](https://sqlitebrowser.org/) |

**Database file name:** `ovgu_exam_attendance.db` (see `ovgu_exam_attendance_app/lib/core/database/database_constants.dart`).

**Tables are not recreated on every app launch.** The first time the app creates the DB file, `onCreate` runs once and creates the `participants` table. Later launches **open the same file**; data persists until you uninstall, clear storage, or change the schema (during development, prefer **uninstall / clear data** after schema edits — see `databaseVersion` comment in code).

**How to inspect tables and data (development)**

1. Run the app so the DB file exists (after any code path that opens the database).
2. **Android emulator:** use `adb` with `run-as` for the debug package id, or copy `databases/ovgu_exam_attendance.db` to your machine, then:
   - `sqlite3 /path/to/ovgu_exam_attendance.db`
   - `.tables` — `SELECT * FROM participants LIMIT 20;`
3. **iOS Simulator:** locate the app container and search for `ovgu_exam_attendance.db`, then open the same way.

**Confidence check:** same idea as Postgres — if `sqlite3` shows your table and rows after an import, the schema and data are real; the only difference is **reaching the file** instead of a connection string.

### Database versioning (`sqflite`)

`openDatabase` **requires** a `version` integer. That is not a cosmetic counter — it is how the library knows whether the **existing file on disk** was created with an **older** schema than your **current** app.

| Situation | What runs |
|-----------|-----------|
| **First install** (no DB file yet) | **`onCreate`** — create tables once. The file’s stored version is set to `DatabaseConstants.databaseVersion`. |
| **Later app opens** (same version) | Neither `onCreate` nor `onUpgrade`; the file is opened as-is. |
| **App update** (you **increase** `databaseVersion` in code) | **`onUpgrade(oldVersion, newVersion)`** — run SQL migrations (`ALTER TABLE`, new tables, data copy, etc.). **After it finishes successfully, sqflite updates the stored version** to match the new constant. |

So the version number is the **official hook for migrations** when you **cannot** ask users to lose data (e.g. Play Store update).

**Development workflow**

- While the schema is still changing freely, you can keep **`databaseVersion` at 1** and **uninstall / clear app storage** after breaking schema edits so `onCreate` runs again. No migration step needed.
- When you prepare a **released** build that must **preserve** existing user data across updates: **bump** `databaseVersion` in `database_constants.dart` and **implement** the migration in `AppDatabase._upgradeDatabase` in `app_database.dart` (one `if (oldVersion < N)` block per step).

**Where to look in code:** `ovgu_exam_attendance_app/lib/core/database/database_constants.dart` (version) and `ovgu_exam_attendance_app/lib/core/database/app_database.dart` (`onCreate`, `onUpgrade`).

## Run the Project (Flutter App)

The Flutter application is in `ovgu_exam_attendance_app`.

Prerequisites:

- Flutter SDK installed (`flutter --version`)
- A connected Android device or running emulator

From the repository root:

1. `cd ovgu_exam_attendance_app`
2. `flutter pub get`
3. `flutter run`

Optional checks:

- `flutter analyze`
- `flutter test`
