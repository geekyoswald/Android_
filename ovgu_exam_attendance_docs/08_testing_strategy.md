# 8. Testing Strategy

## MVP acceptance focus

- Import valid CSV; invalid file rejected with a **simple** message (no import summary screen required).
- Scan path → unique match → confirm present → counters update.
- Duplicate present blocked with clear UI.
- Manual search marks present with same persistence rules.
- **Export:** every participant row has `present` or `absent`; **absent** only for students never confirmed; recomputable on second export.
- Restart app: present records persist.

## Testing Objectives

- Validate that the attendance workflow is reliable under real exam conditions.
- Measure OCR usefulness without allowing it to become a hidden source of wrong attendance records.
- Prove that offline behavior and data persistence are robust.
- Ensure that privacy-sensitive design choices remain intact across releases.

## Test Levels

### Unit Testing

Focus areas:

- OCR text normalization
- matriculation number extraction
- exact-match logic
- duplicate prevention rules
- CSV validation rules
- export formatting

### Integration Testing

Focus areas:

- import into local database
- scan-result handoff to matching service
- attendance persistence
- audit event creation (post-MVP when implemented)
- export generation with correct present/absent derivation

### Device and Workflow Testing

Focus areas:

- camera behavior on approved devices
- OCR responsiveness on target hardware
- scan-to-confirm workflow timing
- recovery after app restart

### Pilot Field Testing

Focus areas:

- realistic exam environment throughput
- invigilator usability under time pressure
- lighting and glare sensitivity
- frequency of manual fallback use

## Functional Test Cases

- import valid participant CSV
- reject unusable CSV with a clear message
- scan valid student ID and match correctly
- detect duplicate student scan
- handle no-match scan cleanly
- use manual search to mark present
- export final attendance CSV with present/absent columns
- (post-MVP) reverse an attendance mark with audit
- reopen app during active session and continue correctly

## Edge Cases

- duplicate matriculation number in import source
- name field missing in one or more rows
- OCR returns partial number only
- OCR returns multiple plausible number strings
- student not on the participant list
- very large participant list compared with normal class size
- multiple rapid scans of the same card
- camera initialization failure
- low battery or power-saving mode affecting performance

## Real-World Exam Environment Testing

The system should be tested in conditions that resemble actual exam operations rather than only ideal laboratory conditions.

Test scenarios should include:

- bright lecture hall lighting
- reflective card glare
- low-light corridor or entry area
- card tilted at different angles
- student movement while the card is presented
- worn or slightly damaged ID cards
- use on lower-end approved Android devices
- operation by different invigilators with minimal training

## Metrics

### Accuracy Metrics

- OCR extraction accuracy for matriculation number
- exact-match success rate
- false positive rate
- false negative rate

### Performance Metrics

- median scan-to-confirmation time
- 95th percentile scan-to-confirmation time
- median manual-search completion time

### Reliability Metrics

- OCR failure rate
- duplicate detection success rate
- crash-free exam session rate
- successful export rate

## Recommended Acceptance Targets

- Median scan-to-confirmation time under 2 seconds on approved devices.
- Zero tolerated silent false-positive attendance marks in controlled testing.
- Manual fallback completion in under 10 seconds for common scenarios.
- No loss of confirmed attendance records after app restart.

## Privacy and Security Verification

Release validation should also include:

- dependency review for hidden network or telemetry code
- manifest review for unnecessary permissions
- local storage inspection to verify no image retention by default
- encryption-at-rest verification (when implemented)
