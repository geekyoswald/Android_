# 11. Future Improvements

## Identity Capture Enhancements

If university policy and card design evolve, future versions could support:

- QR code scanning
- barcode-based identification
- NFC-based student identification
- redesigned machine-readable university ID cards

These options could reduce OCR dependency and improve robustness, but they are explicitly outside the current constraints.

## OCR and Performance Improvements

Potential upgrades:

- automatic card-region detection before OCR
- device-specific OCR tuning
- better candidate ranking using roster-aware heuristics
- improved on-device benchmarking across approved hardware

## Workflow Enhancements

Potential additions:

- seat verification during attendance
- late-arrival tagging
- identity mismatch notes
- manual override reasons for auditability
- session closeout checklist before export

## Administrative Improvements

Potential additions:

- signed or protected export packages
- roster checksum verification on import
- admin-only correction mode
- structured audit export for compliance review

## Privacy-Preserving Analytics

Only if explicitly approved by OVGU governance and data protection stakeholders:

- local aggregate performance metrics
- anonymized operational statistics without student identifiers
- opt-in pilot analytics for scan success and failure patterns

No student-level behavioral analytics should be included by default.

## Platform Expansion

- iOS support once Android deployment and OCR behavior are stable
- tablet-optimized UI for larger screens
- integration with institution-managed mobile device fleets
