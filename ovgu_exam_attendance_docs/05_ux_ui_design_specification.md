# 5. UX / UI Design Specification

## UX Goals

- Minimize invigilator effort during high-throughput check-in.
- Keep the main flow understandable with almost no training.
- Ensure the app remains usable when scanning performs poorly.
- Make system status obvious at a glance.

## Primary Interaction Model

The application should follow a scan-first workflow. The invigilator should spend most of the session on one screen, with rapid transitions into confirmation and back to scanning. Secondary tasks such as search, review, and export should be clearly separated so they do not interfere with the main check-in flow.

## Key Screens

### Scan Screen

Purpose:

- Default operational screen during the exam.

Required elements:

- live camera preview
- card framing guide
- active exam title
- scan status area
- visible manual search action
- attendance counters
- optional torch control

Interaction expectations:

- The screen should open directly into scanning readiness.
- Status should change clearly between `ready`, `processing`, `match found`, and `scan failed`.
- After successful confirmation, the app should return to this screen automatically.

### Confirmation Screen

Purpose:

- Prevent accidental attendance marking.

Required elements:

- student full name
- matriculation number
- optional supporting context such as seat number
- large `Confirm Present` action
- cancel/back action

Interaction expectations:

- The screen should appear only after a unique exact roster match.
- The confirmation action should be visually dominant.
- Cancellation should return to scan mode immediately.

### Manual Search Screen

Purpose:

- Guarantee reliable operation when OCR fails or is uncertain.

Required elements:

- search field
- prompt text explaining accepted input
- result list
- direct mark-present action for each result

Interaction expectations:

- The screen must be reachable within one tap from scan mode.
- Search should support both name and matriculation input.
- Results should update quickly and remain readable in crowded operational conditions.

### Attendance List Screen

Purpose:

- Provide review, correction, and progress visibility.

Required elements:

- full roster list
- attendance status indicator
- filters for present and absent
- search field
- optional undo or correction action where permitted

Interaction expectations:

- This screen is secondary and should not compete with scan mode for attention.
- It should support fast visual verification and troubleshooting.

## Interaction Design Rules

- Keep the happy path to scan, confirm, and return.
- Avoid multi-step dialogs unless required for data integrity.
- Make duplicate warnings visually distinct from normal confirmations.
- Prefer large tap targets and short labels.
- Avoid long paragraphs on operational screens.

## Error Handling UX

Common error states:

- OCR could not read the card.
- OCR produced low-confidence or ambiguous text.
- The extracted number is not in the roster.
- The student is already marked present.
- CSV import contains invalid rows.
- Export failed due to file handling issues.

Design rules for error handling:

- Every error message must explain what happened.
- Every error message must suggest the next action.
- The user should never be trapped in a dead-end state.

Examples of good error behavior:

- `Could not read matriculation number. Try scanning again or use Manual Search.`
- `Student already marked present at 09:12.`
- `Import completed with 3 rejected rows. Review errors before exam start.`

## Accessibility Considerations

- Use high-contrast colors and do not rely only on color for status.
- Use clear typography with sufficient text size for fast reading.
- Provide large buttons suitable for one-handed use.
- Ensure screen-reader compatibility for administrative screens.
- Use optional haptic feedback for successful confirmations and duplicate warnings.

## Offline UX Behavior

- The application should visibly communicate that core operation does not require internet.
- The interface should never suggest retrying network-dependent actions.
- If OCR initialization fails, the app must still expose manual attendance workflows immediately.
- Import and export should use local file interaction patterns only.

## Usability Considerations from Real Exam Environments

- Students may queue quickly, so the UI must recover instantly after each confirmation.
- Glare and movement are normal, so rescan should be fast and low-friction.
- Invigilators may briefly hand off the device to another staff member, so the workflow must remain self-explanatory.
- Bright lecture halls demand stronger contrast and larger visual hierarchy than typical consumer app styling.
