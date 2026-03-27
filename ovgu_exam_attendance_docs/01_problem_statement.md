# 1. Problem Statement

## Background

During university examinations at OVGU, invigilators currently verify student attendance by comparing university ID cards with printed participant lists and marking presence manually. This process is familiar and low-tech, but it becomes inefficient in large exam sessions and creates unnecessary operational pressure shortly before the exam begins.

The university needs a faster and more reliable process that does not depend on internet access, does not require changes to the existing student ID cards, and remains acceptable under GDPR and institutional privacy requirements.

## Current Workflow

1. The exam organizer prepares a printed participant list before the exam.
2. The invigilator receives the list and begins admitting students.
3. Each student presents an ID card containing printed personal data, including name and matriculation number.
4. The invigilator visually reads the card, searches the paper list, and marks the student as present by hand.
5. Corrections, late arrivals, and duplicate checks are handled manually.
6. After the exam, the paper record is stored or transcribed for administrative use.

## Pain Points

- Manual lookup is slow, especially for large classes.
- Long printed lists increase cognitive load and slow down entry flow.
- Attendance marking is prone to human error under time pressure.
- Duplicate detection is inconsistent and depends on individual attention.
- Paper records are difficult to search, export, or audit.
- Corrections are less transparent than structured digital records.
- The process does not scale well in crowded or stressful exam environments.

## Objectives

- Reduce the time needed to verify and mark each student.
- Improve accuracy of attendance marking.
- Support a fast, scan-first workflow with manual fallback.
- Ensure that the entire operational workflow remains usable without internet access.
- Keep all processing and storage local to the device.
- Produce structured attendance output suitable for administrative handling.
- Preserve privacy by minimizing stored data and avoiding unnecessary transmission or retention.
