# Project Structure Guide

This document explains the organization of the `lib/` folder in the Flutter app, what each folder and file contains, and what to expect when navigating the codebase.

## Quick Overview

```
lib/
├── core/                          # Shared infrastructure & utilities
│   ├── database/                  # Database setup & configuration
│   └── theme/                     # App-wide theme & styling
├── features/                      # Feature-specific code (organized by feature)
│   ├── import/                    # CSV import feature
│   │   ├── domain/                # Business logic & data models
│   │   ├── data/                  # Database & API operations
│   │   ├── services/              # Reusable helper logic
│   │   └── presentation/
│   │       └── screens/           # import_screen.dart
│   ├── scan/
│   │   └── presentation/
│   │       └── screens/           # scan_screen.dart (placeholder)
│   ├── participants/
│   │   └── presentation/
│   │       └── screens/           # participant_list_screen.dart (placeholder)
│   └── export/
│       └── presentation/
│           └── screens/           # export_screen.dart (placeholder)
└── main.dart                      # App entry point, OvguAttendanceApp, AppRoutes
```

---

## Detailed Breakdown

### 📦 **`lib/` Root Level**

| File/Folder | Purpose | What You'll Find |
|---|---|---|
| `main.dart` | App entry point & routing | `main()`, `OvguAttendanceApp`, `AppRoutes` (named route constants) |
| `core/` | Shared infrastructure | Database setup, constants, utilities used across features |
| `features/` | Feature-specific code | Organized by feature (import, scanning, etc.); self-contained modules |

---

### 🔧 **`core/` — Shared Infrastructure**

This folder contains code that's shared across the entire app — things like database setup, global constants, and utilities.

```
core/
├── database/
│   ├── app_database.dart          # SQLite database initialization & schema
│   └── database_constants.dart    # Database name, version, table names
├── theme/
│   └── app_theme.dart             # App-wide theme, colors, typography, styles
```

#### **`core/theme/app_theme.dart`**
- **What it is:** Centralized theme definition for the entire app
- **What you'll find:**
  - `AppTheme` class with color constants (primary, secondary, status colors)
  - `lightTheme()` — returns Material 3 `ThemeData` with full customization
  - Helper methods: `statusChip()`, `successTextStyle()`, `errorTextStyle()`, `warningTextStyle()`
  - Spacing constants: `verticalSpacingSmall/Medium/Large`, `horizontalSpacingSmall/Medium/Large`
  - Border radius constants: `borderRadiusSmall/Medium/Large`
- **Why it exists:** Single source of truth for colors, typography, and UI consistency across all screens
- **Used by:** `main.dart` (applies to MaterialApp), and any screen that needs consistent styling

#### **`core/database/app_database.dart`**
- **What it is:** Singleton database instance manager
- **What you'll find:**
  - `AppDatabase` class (singleton pattern)
  - `_openDatabase()` — opens/creates SQLite database
  - `_createParticipantsTable()` — defines participants table schema
  - `_createIndexes()` — creates indexes for fast queries
- **Why it exists:** Ensures only one database connection exists throughout app lifetime
- **Used by:** `ParticipantRepository` (in features/import/data)

#### **`core/database/database_constants.dart`**
- **What it is:** Central place for all database-related constants
- **What you'll find:**
  - `databaseName` — SQLite file name
  - `databaseVersion` — schema version (for migrations)
  - `participantsTable` — table name constant
- **Why it exists:** If database name/version changes, update in one place only
- **Used by:** `app_database.dart`, `ParticipantRepository`

---

### ✨ **`features/` — Feature-Specific Code**

This is where the actual app features live. Each feature is **self-contained** with its own folder. Currently, we have the `import` feature.

```
features/
└── import/                        # CSV Import Feature (isolated module)
    ├── domain/                    # Pure business logic & models
    ├── data/                      # Database & API operations
    └── services/                  # Helper utilities & business logic
```

#### **What to expect in any feature folder:**

When adding a new feature (e.g., `scanning`, `reporting`), follow this structure:

```
features/
└── scanning/                      # New feature example
    ├── domain/
    │   ├── scan_result.dart      # Data models for scanning
    │   └── participant.dart       # Models related to participants
    ├── data/
    │   ├── scan_repository.dart  # Database operations
    │   └── scan_api.dart         # External API calls (if needed)
    ├── services/
    │   ├── qr_scanner.dart       # QR code scanning logic
    │   └── barcode_parser.dart   # Parse barcode data
    └── ui/                        # (optional) UI components if large
        └── scan_screen.dart       # Scan screen widget
```

---

### 📁 **`features/import/` — CSV Import Feature**

This folder handles everything related to importing CSV files with participant data.

#### **1️⃣ `domain/` — Business Logic & Data Models**

**What it contains:** Pure Dart classes that represent business concepts. No database code, no UI code — just data structures.

```
domain/
├── participant_import_row.dart    # Single CSV row as a data model
└── import_result.dart             # Result of parsing a CSV file
```

**`participant_import_row.dart`**
```dart
class ParticipantImportRow {
  final String matriculationNumber;    // Student ID
  final String fullName;               // Student name
  final String examGroup;              // Exam group (optional)
}
```
- **Purpose:** Represents one row from a CSV file
- **When you see it:** Used after parsing CSV, before saving to database

**`import_result.dart`**
```dart
class ImportResult {
  final List<ParticipantImportRow> rows;       // Valid rows
  final List<ImportIssue> errors;              // Hard errors (block import)
  final List<ImportIssue> skippedRows;         // Soft errors (rows skipped)
}

class ImportIssue {
  final int lineNumber;    // Which line in CSV
  final String message;    // What went wrong
}
```
- **Purpose:** Container for all results of parsing a CSV (valid rows + errors)
- **When you see it:** Returned by `CsvParticipantParser.parse()`

---

#### **2️⃣ `data/` — Database & Data Operations**

**What it contains:** Code that talks to the database. This is where data is read from/written to SQLite.

```
data/
└── participant_repository.dart    # Database operations for participants
```

**`participant_repository.dart`**
```dart
class ParticipantRepository {
  Future<void> replaceAllParticipants(List<ParticipantImportRow> rows) async
}
```
- **Purpose:** Single source of truth for database operations
- **What methods do:**
  - `replaceAllParticipants()` — delete all old participants, insert new ones (transaction)
  - (Future) `getParticipantsByGroup()` — fetch participants for a group
  - (Future) `updateAttendanceStatus()` — mark participant as present/absent
- **When you use it:** Whenever you need to save/read participant data to/from database
- **Database connection:** Uses `AppDatabase.instance.database` from core/

---

#### **3️⃣ `services/` — Helper Logic & Utilities**

**What it contains:** Reusable business logic that doesn't fit in `domain/` or `data/`. Often stateless helpers.

```
services/
├── csv_participant_parser.dart    # Parse CSV text into ParticipantImportRow objects
├── csv_import_validator.dart      # Validate CSV file format before parsing
└── csv_text.dart                  # Low-level CSV text utilities
```

**`csv_participant_parser.dart`**
```dart
class CsvParticipantParser {
  static ImportResult parse(String csvContent)
}
```
- **Purpose:** Convert raw CSV text into structured data
- **Input:** Raw CSV file content (String)
- **Output:** `ImportResult` with parsed rows + errors
- **Does:** Splits lines, detects delimiter, extracts columns, validates each row

**`csv_import_validator.dart`**
```dart
class CsvImportValidator {
  static CsvValidationResult validate(String csvContent)
}

class CsvValidationResult {
  final bool isValid;
  final String message;
  final int studentCount;
}
```
- **Purpose:** Quick validation before parsing (checks headers, non-empty, etc.)
- **Input:** Raw CSV text
- **Output:** Valid/invalid + reason
- **Does:** Checks required columns exist, file not empty

**`csv_text.dart`**
```dart
String detectDelimiter(String headerLine)
List<String> parseCsvLine(String line, [String delimiter = ','])
String normalizeCsvHeader(String value)
```
- **Purpose:** Low-level CSV text operations
- **Does:** Auto-detect delimiter, parse single line respecting quotes, normalize header names
- **Reusable:** Used by both validator and parser

---

## Flow Diagram: How Data Moves Through Features

```
User selects CSV file
    ↓
main.dart (ImportScreen)
    ↓
CsvImportValidator.validate()  [services/]
    ↓
CsvParticipantParser.parse()   [services/] → ImportResult
    ↓
ParticipantImportRow objects   [domain/]
    ↓
ParticipantRepository.replaceAllParticipants()  [data/]
    ↓
AppDatabase.instance.database  [core/]
    ↓
SQLite: participants table
```

---

## Architecture Pattern: Clean Architecture Layers

The project follows **Clean Architecture** principles:

```
┌─────────────────────────────────────┐
│  Presentation Layer (UI)            │
│  └─ main.dart (ImportScreen)        │
│     └─ Shows status, handles clicks │
└────────────┬────────────────────────┘
             ↓
┌─────────────────────────────────────┐
│  Domain Layer (Business Logic)       │
│  └─ features/import/domain/         │
│     └─ Models: ImportRow, Result    │
│     └─ No dependencies on DB or UI  │
└────────────┬────────────────────────┘
             ↓
┌─────────────────────────────────────┐
│  Data Layer (Database/API)          │
│  ├─ features/import/data/           │
│  │  └─ ParticipantRepository        │
│  └─ core/database/                  │
│     └─ SQLite setup & config        │
└─────────────────────────────────────┘
```

**Benefits:**
- **domain/** is testable (no DB, no UI)
- **data/** is isolated (only talks to DB)
- **services/** are reusable helpers
- Easy to swap implementations (e.g., switch database)

---

## What Goes Where: Decision Guide

When adding new code, ask yourself:

| Question | Answer → Location |
|---|---|
| Is it a data model? | `domain/` |
| Does it touch the database? | `data/` |
| Is it a reusable utility/helper? | `services/` |
| Is it global configuration? | `core/` |
| Is it a UI screen? | `main.dart` (or `features/[feature]/ui/` if large) |

---

## Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Feature folder | lowercase, snake_case | `import/`, `scanning/` |
| Domain models | PascalCase | `ParticipantImportRow`, `ImportResult` |
| Repository class | `[Entity]Repository` | `ParticipantRepository` |
| Service class | `[Feature][Action]Service` or utility | `CsvParticipantParser`, `CsvImportValidator` |
| File name | snake_case.dart | `participant_import_row.dart` |
| Database constant | SCREAMING_SNAKE_CASE | `DatabaseConstants.participantsTable` |

---

## Expanding the Project

### Adding a New Feature (e.g., Scanning)

```
Step 1: Create folder structure
features/scanning/
├── domain/
│   ├── scan_result.dart
│   └── barcode_data.dart
├── data/
│   └── scan_repository.dart
└── services/
    ├── qr_scanner_service.dart
    └── barcode_parser.dart

Step 2: Define domain models first
→ domain/scan_result.dart

Step 3: Create repository for database
→ data/scan_repository.dart (uses AppDatabase from core/)

Step 4: Write helper services
→ services/ (reusable logic)

Step 5: Add UI screen in main.dart
→ Inject repositories and services
→ Call services, update UI based on results
```

---

## Testing Structure

Tests are organized by type for clarity:

```
test/
├── unit/
│   ├── csv_text_test.dart             # Tests for csv_text.dart utilities
│   ├── csv_import_validator_test.dart # Tests for CSV validation
│   └── csv_participant_parser_test.dart # Tests for CSV parsing
├── integration/
│   └── csv_import_integration_test.dart # Tests with real CSV files from disk
└── widget_test.dart                   # UI/widget tests
```

**Running Tests:**
```bash
flutter test                    # Run all tests
flutter test test/unit/         # Run unit tests only
flutter test test/integration/  # Run integration tests only
```

---

## Current Status & Missing Pieces

| Component | Status | Notes |
|---|---|---|
| `core/database/` | ✅ Complete | SQLite setup done |
| `core/theme/` | ✅ Complete | App theme with colors, typography, spacing, status indicators |
| `features/import/domain/` | ✅ Complete | Models defined |
| `features/import/data/` | ✅ Fixed | Schema updated to match DB (was: `is_present`, now: `status`, added `exam_group`) |
| `features/import/services/` | ✅ Complete | Parser & validator done |
| `features/import/presentation/screens/` | ✅ Complete | ImportScreen with import result card |
| `test/unit/` | ✅ Complete | 86 unit tests for CSV logic |
| `test/integration/` | ✅ Complete | Integration tests with real CSV files |
| `test_csv_files/` | ✅ Complete | 18 test CSVs covering all scenarios |
| `features/scan/` | ❌ Not started | Placeholder exists, needs implementation |
| `features/participants/` | ❌ Not started | Placeholder exists, needs implementation |
| `features/export/` | ❌ Not started | Placeholder exists, needs implementation |

---

## Quick Reference: File Locations

| What you need | Where to find it |
|---|---|
| Database connection | `core/database/app_database.dart` |
| Table names/versions | `core/database/database_constants.dart` |
| App colors, typography, styles | `core/theme/app_theme.dart` |
| Participant data model | `features/import/domain/participant_import_row.dart` |
| Parse results | `features/import/domain/import_result.dart` |
| Save to database | `features/import/data/participant_repository.dart` |
| Parse CSV | `features/import/services/csv_participant_parser.dart` |
| Validate CSV | `features/import/services/csv_import_validator.dart` |
| CSV text utilities | `features/import/services/csv_text.dart` |
| App entry & routing | `main.dart` |
| Import screen | `features/import/presentation/screens/import_screen.dart` |

---

## Summary

- **`core/`** = App-wide infrastructure (database, shared config)
- **`features/`** = Self-contained features (each feature is independent)
  - **`domain/`** = Data models & business logic (no DB, no UI)
  - **`data/`** = Database operations (repositories)
  - **`services/`** = Reusable helpers & business logic
- **`main.dart`** = UI screens & app entry point

This structure makes code **reusable**, **testable**, and **easy to understand**.
