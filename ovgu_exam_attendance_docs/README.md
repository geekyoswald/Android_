# OVGU Exam Attendance System Documentation

This folder contains a complete documentation package for the proposed mobile attendance system for OVGU exam invigilation.

## Document Index

1. [01_problem_statement.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/01_problem_statement.md)
2. [02_product_requirements_document.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/02_product_requirements_document.md)
3. [03_system_architecture_and_design.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/03_system_architecture_and_design.md)
4. [04_data_model_design.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/04_data_model_design.md)
5. [05_ux_ui_design_specification.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/05_ux_ui_design_specification.md)
6. [06_ocr_and_scanning_strategy.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/06_ocr_and_scanning_strategy.md)
7. [07_security_and_privacy_design.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/07_security_and_privacy_design.md)
8. [08_testing_strategy.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/08_testing_strategy.md)
9. [09_deployment_and_distribution_plan.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/09_deployment_and_distribution_plan.md)
10. [10_risks_and_mitigations.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/10_risks_and_mitigations.md)
11. [11_future_improvements.md](/Users/sakshamgupta/Desktop/deepseek/codexapp/ovgu_exam_attendance_docs/11_future_improvements.md)

## Scope

The documentation describes a GDPR-conscious, offline-first mobile application for exam invigilators at Otto von Guericke University Magdeburg (OVGU). The system is intended to replace manual attendance marking based on printed lists by enabling local OCR-based identification from student ID cards and structured attendance recording on a single mobile device.

## Design Principles

- Reliability under real exam conditions takes priority over feature breadth.
- Offline operation is mandatory for all core workflows.
- Privacy by design and data minimization are central architectural requirements.
- Manual fallback must always be available when scanning fails.
- The target experience is fast enough for high-throughput exam entry scenarios.

## Recommended Implementation Profile

- Platform: Flutter, Android-first, with iOS support as a later extension.
- OCR: On-device OCR only, with no cloud services and no external APIs.
- Local persistence: Encrypted SQLite database in app-private storage.
- Distribution: Institution-controlled APK deployment on approved exam devices.
