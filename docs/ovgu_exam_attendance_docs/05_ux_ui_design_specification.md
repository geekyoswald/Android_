# 5. UX / UI Design Specification

## MVP UX goals

- Minimal screens: **import CSV → start scanning / manual search → confirm present → see counts → export**.
- During check-in, show **present count** and **not-yet-marked count** prominently. If `exam_group` is present in CSV, show **per-exam live counts** (e.g. "EinfInf 144/164 · AuD 10/16"). Do **not** label students "absent" in the live UI.
- On **Export**, produce a CSV where **`absent` means "no present record at export time."** Show clear copy: unmarked students will appear as absent in the file.
- Manual fallback always one easy action away from scan mode.
- **No audio signals.** Use **short haptic vibration** only for successful confirmation. Failures are visual-only (no vibration on no-match or wrong input).

## Primary interaction model (MVP)

1. User lands on **Import** (or app opens to import if no participant list is loaded).
2. After successful import, inline **import result card** shows: count, any skipped rows with line numbers, duplicates. User dismisses with OK.
3. User taps **Start scanning** to enter the operational loop.
4. Happy path: scan → single large tap to confirm → haptic pulse → return to scan; counters update.
5. Fallback: **Manual search** from scan screen (unified single field) → select result → confirm.
6. **Export** available from the main flow once a list is loaded; warn about absent semantics before writing.

## Key screens

### Import screen (MVP mandatory)

Purpose: load the participant list from a CSV on the device.

Required elements:

- File pick / "Import CSV" primary action.
- **Inline import result card** (not a separate screen) after import:
  - Success: "Imported 154 students." or per-exam breakdown (e.g. "Imported 144 EinfInf, 10 AuD students.").
  - Errors: all failing rows listed with line numbers (scrollable). User fixes file on PC and re-imports.
  - Warnings: duplicate matriculation within same exam group, with line numbers.
  - Skipped guest rows: "1 entry not imported — line 122: missing matriculation number."
  - OK button to dismiss.
- Path to **Start scanning** once import succeeds.

### Scan screen (MVP mandatory)

Purpose: default screen during check-in.

Required elements:

- Camera preview and framing guidance.
- **Present** and **not yet marked** counts (not "absent"). If `exam_group` present: per-exam counts visible.
- **Manual search** entry (unified field — name or matric).
- **Export** control (or overflow menu; must remain discoverable).
- **Participant list** accessible from this screen (e.g. tab or floating action button).

Interaction:

- After confirm: haptic pulse → return to scan readiness; counters refresh immediately.
- On OCR no-match: show extracted matric + "Not found in participant list." + **[Rescan]** and **[Manual search]** buttons. No blocking dialog.
- On already-marked rescan: show "Max Müller already marked [status]." + **[Change status]** and **[Cancel]** buttons.

### Confirmation screen (MVP mandatory)

Purpose: prevent mistaken marks.

Required elements:

- Full name, matriculation number, exam_group (if applicable).
- **Dominant single large tap target** — a large "✓ Confirm" / checkmark button; cancel/back alongside it.
- No confirmation dialog — one tap is enough.
- Haptic vibration fires on this tap.

If student is in **multiple exam groups**: show disambiguation first — "Max Müller found in EinfInf (graded) and EinfInf (ungraded). Which exam?" → select → then confirm.

### Manual search screen (MVP mandatory)

Purpose: reliable path when OCR fails.

Required elements:

- **Single unified search field** — user types anything (name, surname fragment, matriculation digits).
- Live-updating result list below field (no separate search button).
- Tap a result row to open the same confirmation flow as scan.
- If no results: "Student not in list." + **[Back to scanning]** button.

### Participant list screen (MVP mandatory)

Purpose: full fallback when everything else fails; also used for status correction.

Required elements:

- Scrollable list of **all** participants.
- Each row shows: name, matriculation, exam_group (if any), current status (present / excused / marked / not yet marked).
- **Sort control**: sort by matriculation number, surname, or full name. Sort preference persists for the session.
- Tap a row to open status-change flow (same options as rescan: present, excused, marked, not_marked).
- Search / filter within the list (reuse the unified search field pattern).

### Status change flow (inline)

Triggered by: rescanning an already-marked student, or tapping a row in the participant list.

Options presented:

| Option | When to use |
|--------|-------------|
| Present | Confirm attendance |
| Excused | Student has doctor's note or approved reason |
| Marked | Flag for follow-up (e.g. suspected fraud / ID mismatch) |
| Not marked (undo) | Remove the current status; resets to absent on export |

No extra "are you sure" dialog — one tap on the desired status applies it.

## Interaction design rules

- Happy path: scan → single-tap confirm → back to scan in minimal steps.
- Large tap targets throughout; readable in bright exam hall lighting.
- Errors always suggest **next action** (rescan, manual search).
- No blocking dialogs — always one tap to recover from any failure state.
- Haptic feedback only on success; never on failure (prevents confusing success/failure signals).

## Error handling UX (MVP)

| Situation | Response |
|-----------|----------|
| OCR unreadable | Suggest rescan or manual search |
| OCR no match | Show extracted matric + [Rescan] [Manual search] |
| Already marked (rescan) | Show current status + [Change status] [Cancel] |
| Import error | Inline card with all errors + line numbers; OK to dismiss |
| Export failure | Explain and suggest retry; no partial silent failure |
| Manual search no match | "Student not in list." + [Back to scanning] |

## Accessibility and environment

- High contrast, large targets, readable in bright rooms.
- Sort and search available at all times.
- Participant list as final fallback if scanning and search both fail.

## Offline UX

- No network messaging; import/export via local file APIs only.
- If camera unavailable, manual search, participant list, and export still work if a participant list is loaded.
