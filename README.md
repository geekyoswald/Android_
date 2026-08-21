# OVGU Exam Attendance App

A Flutter app for tracking student attendance during exam invigilation at OVGU — import a participant CSV, mark students present via ID card OCR scanning or manual search, and export a final attendance CSV. Runs fully **offline**, no cloud APIs.

The app itself lives in [`ovgu_exam_attendance_app/`](ovgu_exam_attendance_app/). Full design and process documentation lives in [`docs/ovgu_exam_attendance_docs/`](docs/ovgu_exam_attendance_docs/).

## Core Flow

1. **Import** a **CSV file on the device** listing **participants** for the exam (matriculation number and full name; German OVGU exports with `mtknr`/`nachname`/`vorname` are also supported).
2. **Mark students present** during the exam using **ID card scanning** (on-device OCR → match the **participant list**) **or manual search** (same confirmation rules). Manual path always works if scanning fails.
3. **During the session**, the app shows **how many are present** and **how many are not yet marked** (total minus present). The UI does not label anyone "absent" until export.
4. **Export** via an explicit control: write a **CSV** where each **imported participant row** has **`present`** or **`absent`**. **`absent` is assigned only at export time**: any student without a confirmed present record at that moment is exported as absent.

Further enhancements (sessions with metadata, full participant review screens, audit trails, encryption hardening, corrections, and so on) are documented in [11_future_improvements.md](docs/ovgu_exam_attendance_docs/11_future_improvements.md) and called out in individual documents.

## Documentation Index

All docs are in [`docs/ovgu_exam_attendance_docs/`](docs/ovgu_exam_attendance_docs/):

1. [01_problem_statement.md](docs/ovgu_exam_attendance_docs/01_problem_statement.md)
2. [02_product_requirements_document.md](docs/ovgu_exam_attendance_docs/02_product_requirements_document.md)
3. [03_system_architecture_and_design.md](docs/ovgu_exam_attendance_docs/03_system_architecture_and_design.md)
4. [04_data_model_design.md](docs/ovgu_exam_attendance_docs/04_data_model_design.md)
5. [05_ux_ui_design_specification.md](docs/ovgu_exam_attendance_docs/05_ux_ui_design_specification.md)
6. [06_ocr_and_scanning_strategy.md](docs/ovgu_exam_attendance_docs/06_ocr_and_scanning_strategy.md)
7. [07_security_and_privacy_design.md](docs/ovgu_exam_attendance_docs/07_security_and_privacy_design.md)
8. [08_testing_strategy.md](docs/ovgu_exam_attendance_docs/08_testing_strategy.md)
9. [09_deployment_and_distribution_plan.md](docs/ovgu_exam_attendance_docs/09_deployment_and_distribution_plan.md)
10. [10_risks_and_mitigations.md](docs/ovgu_exam_attendance_docs/10_risks_and_mitigations.md)
11. [11_future_improvements.md](docs/ovgu_exam_attendance_docs/11_future_improvements.md)
12. [12_phased_development_roadmap.md](docs/ovgu_exam_attendance_docs/12_phased_development_roadmap.md)
13. [13_project_structure_guide.md](docs/ovgu_exam_attendance_docs/13_project_structure_guide.md) — how to navigate the codebase: folder structure, architecture layers, naming conventions, and where to add new code
14. [14_testing_guide.md](docs/ovgu_exam_attendance_docs/14_testing_guide.md) — testing approach: unit tests, integration tests, test CSV files, and how to run tests

## Design Principles

- Reliability under real exam conditions over feature breadth.
- Offline operation for all core workflows.
- Privacy by design and data minimization.
- Manual fallback must always be available when scanning fails.

## Implementation Profile

- Platform: Flutter, Android-first, with iOS support as a later extension.
- OCR: On-device OCR only, with no cloud services and no external APIs.
- Local persistence: SQLite in app-private storage.
- Distribution: Institution-controlled APK deployment on approved exam devices.

## Run the Project

Prerequisites:

- Flutter SDK installed (`flutter --version`)
- A connected Android device or running emulator

From the repository root:

```bash
cd ovgu_exam_attendance_app
flutter pub get
flutter run
```

Optional checks:

```bash
flutter analyze
flutter test
```

## Local Storage (SQLite)

The database file (`ovgu_exam_attendance.db`) lives in each install's app-private storage — not in this git repo. See [13_project_structure_guide.md](docs/ovgu_exam_attendance_docs/13_project_structure_guide.md) and [14_testing_guide.md](docs/ovgu_exam_attendance_docs/14_testing_guide.md) for details on inspecting data and running tests.
