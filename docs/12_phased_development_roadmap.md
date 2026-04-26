# 12. Phased Development Roadmap

## MVP outcome (docs alignment)

The **MVP** to aim for matches [02_product_requirements_document.md](02_product_requirements_document.md):

- **Import** participant CSV from device.
- **Scan** (on-device OCR) + **manual search** → confirm **present**; **duplicate** blocked.
- **Live counts:** present and **not yet marked** (no “absent” label in UI).
- **Export** CSV: each row **`present`** or **`absent`**; **`absent` = no present record at export time**.

Phases below build toward that; you can **ship MVP** once import, persistence, scan/manual, counts, and export (with absent derivation) work. Later phases add robustness, polish, and items from [11_future_improvements.md](11_future_improvements.md).

## Purpose

This roadmap is designed for a developer who is strong in web engineering but new to Flutter and mobile development. The sequence is intentionally incremental. Each phase produces a usable artifact, isolates one major learning area at a time, and avoids introducing OCR or mobile complexity before the underlying app structure is stable.

The guiding principle is simple: build confidence first, then capability, then robustness.

## Phase 1: Flutter Foundations & Project Skeleton

### Goal

Establish a clean Flutter project structure and become comfortable with the basic mobile development workflow before building any attendance logic.

### Features to Implement

- Create the Flutter app and confirm Android build and run flow.
- Set up basic folder structure for screens, domain models, services, and data layer.
- Add simple app navigation between placeholder screens.
- Define a basic visual theme and typography.
- Add a mock exam session screen with static sample data.

### What to KEEP SIMPLE

- No local database yet.
- No CSV import or export.
- No camera.
- No OCR.
- No advanced architecture patterns beyond what you can clearly explain to yourself.

### Technical Focus

- Flutter project anatomy
- widgets, layout, navigation, and state basics
- emulator and device workflow
- hot reload, debugging, and platform permissions awareness

### Deliverable

A runnable Flutter app with a clean structure, multiple placeholder screens, and a basic exam attendance UI shell using static data.

## Phase 2: Manual Attendance MVP

### Goal

Build the core attendance workflow without any scanning complexity so the business flow is proven first.

### Features to Implement

- Show a participant list from in-memory sample data.
- Add manual search by name and matriculation number.
- Allow marking a student as present.
- Show attendance counters.
- Prevent duplicate marking in the UI flow.
- Add a simple attendance list or status view.

### What to KEEP SIMPLE

- Keep data in memory only.
- Do not add persistence yet.
- Do not optimize for very large participant lists yet.
- Do not build an audit log yet.
- Do not introduce OCR or camera placeholders unless they are just navigation stubs.

### Technical Focus

- local app state
- list rendering and search interaction
- state updates after user actions
- designing a workflow around one primary operational screen

### Deliverable

A working manual attendance app that can simulate an exam flow end-to-end using sample data during a single app session.

## Phase 3: Offline Persistence & Data Layer

### Goal

Persist the manual attendance workflow locally so the app becomes genuinely offline-first instead of session-only.

### Features to Implement

- Add local database storage for students, exam session, and attendance records.
- Seed the database with test participant data.
- Restore app state after restart.
- Persist each attendance confirmation immediately.
- Keep manual search and duplicate prevention working on persisted data.

### What to KEEP SIMPLE

- Still no camera or OCR.
- Avoid encryption at rest in the first pass if it blocks learning; model the storage layer cleanly so security can be added next.
- Do not build export yet.
- Do not over-abstract repositories if you only have one local storage implementation.

### Technical Focus

- mobile local persistence
- repository pattern in a practical, not academic, form
- async data loading and UI state transitions
- thinking about app restarts and failure recovery

### Deliverable

A manual attendance application that works offline, survives app restarts, and persists attendance locally.

## Phase 4: Basic Session Management & Data Quality Controls

### Goal

Strengthen the core product before adding scanning by making the data model and operational flow more realistic. **For strict MVP**, this phase can be **skipped or minimized**: one implicit participant list and minimal import validation may suffice; named sessions and audit trail can wait.

### Features to Implement

- **Post-MVP / optional early:** Add explicit exam session creation or selection.
- Support one active exam at a time.
- Add simple validation rules for participant CSV shape.
- Introduce a minimal audit trail for key user actions (**post-MVP** for minimal product).
- Add a dedicated attendance overview screen (**MVP needs counts on scan screen; full list optional**).

### What to KEEP SIMPLE

- No CSV import yet if your data layer is still settling.
- No performance tuning beyond obvious bottlenecks.
- No multi-user or multi-device concepts.
- No role-based permissions.

### Technical Focus

- domain modeling
- state boundaries between session, participant list, and attendance
- designing for data integrity before adding complex input channels

### Deliverable

A stable offline attendance app with realistic exam-session behavior and a trustworthy local data model.

## Phase 5: Camera Integration Sandbox

### Goal

Learn mobile camera integration in isolation before combining it with OCR or attendance logic.

### Features to Implement

- Add a dedicated camera test screen.
- Request and handle camera permissions correctly.
- Show live camera preview.
- Capture a frame or photo.
- Handle common camera lifecycle issues such as app pause and resume.

### What to KEEP SIMPLE

- Do not connect camera output to attendance logic yet.
- Do not run OCR on live frames yet.
- Do not optimize scanning UX beyond basic framing and capture.
- Do not build platform-specific camera customizations unless necessary.

### Technical Focus

- mobile permissions
- camera lifecycle and preview behavior
- performance impact of image capture
- differences between emulator behavior and real device behavior

### Deliverable

A separate in-app camera screen that reliably opens, previews, captures, and recovers from common lifecycle events on a real Android device.

## Phase 6: OCR Integration Sandbox

### Goal

Prove that on-device OCR can reliably extract a matriculation number before wiring it into the attendance workflow.

### Features to Implement

- Integrate an on-device OCR engine.
- Run OCR on captured test images and camera captures.
- Display raw OCR output for debugging.
- Add matriculation-number extraction and normalization logic.
- Build a simple confidence classification such as high, medium, and low.

### What to KEEP SIMPLE

- Do not auto-mark attendance.
- Do not build fuzzy matching.
- Do not optimize for perfect OCR yet.
- Do not store raw images long term.

### Technical Focus

- evaluating OCR behavior on real student card samples
- parsing and normalization
- understanding failure patterns such as glare, blur, and character confusion
- separating OCR output from domain decisions

### Deliverable

A testable OCR workflow that can capture or load an image, extract text locally, and identify a candidate matriculation number with visible debug feedback.

## Phase 7: Full Scan-to-Match MVP

### Goal

Connect scanning, OCR, and attendance into one practical exam workflow while keeping the rules conservative.

### Features to Implement

- Connect camera capture to OCR processing.
- Match extracted matriculation numbers against the local **participant list**.
- Show a confirmation screen for unique exact matches.
- Mark attendance after explicit confirmation.
- Detect duplicates and show a warning state.
- Preserve manual search as a fallback from the scan screen.

### What to KEEP SIMPLE

- No fuzzy matching beyond safe normalization.
- No advanced real-time frame processing if single-capture flow is good enough.
- **Product MVP:** CSV export (with `absent` at export time) may already exist from Phase 8 work done early—this phase focuses on the **scan path**, not on delaying export.
- No visual polish work unless it blocks usability.

### Technical Focus

- end-to-end workflow integration
- asynchronous pipeline management
- balancing automation with correctness
- keeping the manual fallback path first-class

### Deliverable

A usable scan workflow: invigilator can scan a card, get a unique match, confirm attendance, handle duplicates, and fall back to manual search when scanning fails (export may already be in place per roadmap note above).

## Phase 8: Import/Export & Exam Operations

### Goal

Move from a demo-quality system to an operational tool by enabling real participant CSV input and attendance output—with **export defining `absent`** for any row without a present record ([02_product_requirements_document.md](02_product_requirements_document.md)).

### Features to Implement

- Import participant list from local CSV.
- Minimal validation; **MVP:** no post-import summary screen (clear error only if unusable).
- Replace or reset the active participant list safely when importing again.
- Export attendance to local CSV: **`present` / `absent`** per row, absent computed at export time.
- For **present** rows, include **`method`** (`scan` / `manual`) if stored; **MVP:** no time columns.

### What to KEEP SIMPLE

- Do not support every possible CSV variant at once.
- Do not build complex admin workflows.
- Do not add cloud backup or syncing.
- Do not add spreadsheet-style editing inside the app.

### Technical Focus

- file handling on mobile
- input validation and clear failure messages when needed
- designing import/export flows that are safe and understandable offline

### Deliverable

A real operational build that can take a participant CSV before the exam and produce an attendance file after the exam without requiring internet access.

## Phase 9: Reliability Hardening

### Goal

Improve the system where real-world mobile products usually fail: edge cases, recovery, and consistency under stress.

### Features to Implement

- Handle app restarts cleanly during an active exam.
- Add better duplicate handling and correction flow.
- Improve error states for OCR failure, no-match, and malformed import.
- Tune scan timing and reduce unnecessary OCR work.
- Add stronger persistence and data integrity checks.

### What to KEEP SIMPLE

- Avoid large refactors unless a clear structural problem exists.
- Do not chase micro-optimizations before measuring real bottlenecks.
- Do not expand scope into analytics, sync, or advanced admin features.

### Technical Focus

- robustness under failure
- operational testing on real hardware
- performance measurement
- identifying what actually matters in production-like conditions

### Deliverable

A stable, field-testable version that behaves predictably under real exam conditions and recovers well from common failure modes.

## Phase 10: UX Polish, Privacy Hardening & Release Preparation

### Goal

Bring the app from technically functional to professionally usable and institution-ready.

### Features to Implement

- Polish scan, confirmation, and manual fallback interactions.
- Improve contrast, spacing, feedback states, and accessibility basics.
- Add local data retention and deletion behavior.
- Introduce encryption at rest if not already added.
- Review permissions and ensure no accidental networking capabilities are present.
- Prepare installation and pilot usage documentation.

### What to KEEP SIMPLE

- No unnecessary visual flourishes.
- No feature expansion during polish.
- No cross-platform iOS work until Android is stable and reviewed.

### Technical Focus

- product finishing
- privacy-by-design implementation details
- permission review
- preparing a pilot-ready build instead of endlessly extending the MVP

### Deliverable

A pilot-ready Android application that is usable, privacy-conscious, and documented well enough for supervised testing in an academic setting.

## Development Principles

- Do not move to the next phase until the current one is demonstrably usable on a real device where relevant.
- Favor one clear working path over multiple partially working paths.
- Treat OCR as an enhancement to a proven attendance workflow, not the foundation of the app.
- Keep architecture one step ahead of current needs, not five steps ahead.
- Test the same workflow repeatedly in realistic conditions before declaring a phase complete.
- Write short implementation notes for yourself after each phase so your learning compounds instead of resetting.
- If a phase becomes confusing, shrink scope rather than adding abstractions.

## Common Mistakes to Avoid

- Starting with OCR before the manual attendance flow is solid.
- Designing an elaborate architecture before understanding Flutter state and navigation.
- Treating mobile like web and delaying real-device testing too long.
- Over-investing in camera live-stream processing before a simple capture-based workflow works.
- Adding fuzzy matching too early and risking false attendance marks.
- Building import and export too late to influence the data model cleanly.
- Trying to support Android and iOS equally from day one.
- Storing more personal data than is operationally necessary.

## Suggested Timeline

This is a realistic but not aggressive plan for a solo developer learning Flutter while building the product seriously.

### Weeks 1-2

- Phase 1
- Phase 2

Focus:

- Flutter basics
- UI composition
- manual attendance flow

### Weeks 3-4

- Phase 3
- Phase 4

Focus:

- local persistence
- data modeling
- session structure

### Weeks 5-6

- Phase 5
- Phase 6

Focus:

- camera integration
- OCR evaluation
- real-device behavior

### Weeks 7-8

- Phase 7

Focus:

- full scan pipeline
- conservative matching
- fallback behavior

### Weeks 9-10

- Phase 8
- Phase 9

Focus:

- CSV import and export
- reliability improvements
- exam-like testing

### Weeks 11-12

- Phase 10

Focus:

- UX polish
- privacy hardening
- pilot preparation

## Readiness Criteria Before Advancing

- The current phase works without hand-waving or manual developer-only steps.
- You can explain the current architecture in plain language.
- The primary workflow has been tested on a real Android device where relevant.
- You know which problems are intentionally deferred rather than accidentally ignored.

## Final Recommendation

If a phase starts feeling too large, split it. The best roadmap is the one that keeps momentum without hiding complexity. For this project, the highest leverage path is to master the manual attendance system first, then treat camera and OCR as carefully integrated inputs layered on top of a workflow you already trust.

**To reach documented MVP quickly:** prioritize Phases 1–3, then **CSV import and export** with **`absent` derived at export time** (bring Phase 8 pieces forward), then Phases 5–7 for scan and OCR. Confirm export semantics with stakeholders before pilot.
