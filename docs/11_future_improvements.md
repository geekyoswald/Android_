# 11. Future Improvements

Items below extend beyond the **MVP** defined in [02_product_requirements_document.md](02_product_requirements_document.md) and [README.md](README.md). They can be added incrementally without changing the core MVP loop (import → scan/manual → counts → export with present/absent).

## Product and workflow depth

- **Stored timestamps:** `marked_at` / `created_at` (or similar) on records, time in duplicate warnings, and optional time columns in export for administration.
- **Named exam sessions:** title, date, exam id; draft / active / closed lifecycle; one active session per device.
- **Full participant list screen:** scrollable list, search, filters (present / not yet marked); optional quick audit of who remains.
- **Post-import report:** row counts, rejected rows, and reasons (richer than MVP).
- **Attendance reversal / correction** with explicit reason and audit entries.
- **Richer import:** checksum of CSV, version display, safer replace rules for duplicate matriculations.
- **Export variants:** extra columns (seat, program), institution-specific templates, signed export packages.
- **Session closeout checklist** before export (e.g. confirm “no more arrivals”).

## Identity capture enhancements

If university policy and card design evolve:

- QR code, barcode, or NFC (currently out of scope by constraint).
- Redesigned machine-readable ID cards.

## OCR and performance

- Automatic card-region detection before OCR.
- Device-specific OCR tuning and **list-aware** candidate ranking.
- On-device benchmarking across approved hardware.
- Optional retention of minimized OCR excerpts for support (policy-gated).

## Administrative and compliance

- **Structured audit trail** in DB: import, mark present, duplicate, revert, export.
- **Encryption at rest** for SQLite and key management via platform keystore.
- Formal **retention and deletion** flows after export.
- Admin-only correction mode.

## Privacy-preserving analytics (governance only)

With explicit OVGU approval:

- local aggregate metrics (no student identifiers)
- opt-in pilot stats for scan success/failure patterns

Never default student-level behavioral analytics.

## Platform expansion

- iOS after Android stability
- Tablet layouts
- Deeper MDM integration

## UX polish

- Undo flows, haptics, accessibility audits
- Stronger guidance for glare and low light

All of the above can be scheduled **after** the MVP is stable in the field.
