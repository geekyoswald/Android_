# 5. UX / UI Design Specification

## MVP UX goals

- Minimal screens: **import CSV → start scanning / manual search → confirm present → see counts → export**.
- During check-in, show **present count** and **not-yet-marked count** prominently. Do **not** label students “absent” in the live UI.
- On **Export**, produce a CSV where **`absent` means “no present record at export time.”** Show clear copy: unmarked students will appear as absent in the file.
- Manual fallback always one easy action away from scan mode.

Full-product extras (full participant browser, filters, session dashboards) are **post-MVP** unless added opportunistically without blocking ship.

## Primary interaction model (MVP)

1. User lands on **Import** (or app opens to import if no participant list is loaded).
2. After successful import, user taps **Start scanning** to enter the operational loop.
3. Happy path: scan → confirm → return to scan; counters update.
4. Fallback: **Manual search** from scan screen → select → confirm.
5. **Export** available from the main flow once a list is loaded; confirm intent and warn about absent semantics.

## Key screens

### Import screen (MVP mandatory)

Purpose: load the participant list from a CSV on the device.

Required elements:

- File pick / “Import CSV” primary action.
- Path to **Start scanning** once import succeeds.

**MVP:** no separate import summary screen; unusable files may show a simple error only.

### Scan screen (MVP mandatory)

Purpose: default screen during check-in.

Required elements:

- Camera preview and framing guidance (implementation-dependent).
- **Present** and **not yet marked** counts (not “absent”).
- **Manual search** entry.
- **Export** control (or overflow menu if space constrained; must remain discoverable).

Interaction:

- After confirm, return to scan readiness; counters refresh immediately.

### Confirmation screen (MVP mandatory)

Purpose: prevent mistaken marks.

Required elements:

- Full name, matriculation number.
- Dominant **Confirm present**; cancel/back.

### Manual search screen (MVP mandatory)

Purpose: reliable path when OCR fails.

Required elements:

- Search field (name and matriculation).
- Result list; tap to open same confirmation pattern as scan.

### Attendance list / filters (post-MVP or optional)

A full scrollable list of all participants with chips, search, and filters is **not required for MVP**. May be added later per [11_future_improvements.md](11_future_improvements.md).

## Interaction design rules

- Happy path: scan → confirm → back to scan in few taps.
- Duplicate present: distinct warning (**MVP:** no “marked at time” in the message unless timestamps are added later).
- Errors: always suggest **rescan** or **manual search**.

## Error handling UX (MVP)

- OCR unreadable / no match: lead to rescan or manual search.
- Duplicate: e.g. `Student already marked present` (no time-of-mark in MVP).
- Import: if the file cannot be used, show a short error; cannot start scanning until a valid import exists.
- Export failure: explain and suggest retry; no partial silent failure.

## Accessibility and environment

- High contrast, large targets, readable in bright rooms (full details unchanged from institution needs).

## Offline UX

- No network messaging; import/export via local file APIs only.
- If camera unavailable, manual search and export still work if a participant list is loaded.
