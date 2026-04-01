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
