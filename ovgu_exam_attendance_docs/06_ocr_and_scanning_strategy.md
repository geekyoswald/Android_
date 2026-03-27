# 6. OCR & Scanning Strategy

## Objective

The OCR subsystem should extract only the information necessary for attendance matching, namely the matriculation number. The design should not attempt full semantic interpretation of the entire card if the required operational outcome can be achieved more reliably through constrained extraction.

## Recommended Processing Pipeline

1. Open the camera in a guided scan mode.
2. Capture a frame or still image when the card is positioned acceptably.
3. Run on-device OCR on the relevant image region.
4. Normalize OCR output.
5. Extract candidate matriculation numbers using format-aware rules.
6. Rank candidates by validity, confidence, and roster match.
7. Continue only when a unique exact roster match exists.

## Matriculation Number Extraction Strategy

Primary rules:

- Treat the matriculation number as the primary identifier.
- Normalize whitespace and common OCR character confusions.
- Prefer candidates that match the expected length and format for OVGU data.
- Prefer candidates that produce an exact match in the active exam roster.

Recommended post-processing:

- remove spaces inside candidate number strings
- normalize visually similar characters only where safe
- reject incomplete or overlong candidates
- preserve the original OCR text separately only if diagnostic retention is needed

## Handling OCR Errors

Expected OCR failure modes:

- `0` recognized as `O`
- `1` recognized as `I` or lowercase `l`
- split number across multiple text segments
- missing digits due to blur or glare
- false positives from surrounding printed text

Mitigation strategy:

- Use conservative normalization rules.
- Require exact roster match before confirmation.
- Avoid fuzzy attendance marking based solely on OCR similarity.
- Provide immediate rescan and manual fallback.

## Confidence Thresholding

The system should apply operational confidence categories rather than trusting raw OCR confidence alone.

### High Confidence

- OCR output contains one plausible candidate.
- Candidate normalization results in a unique exact roster match.
- The system may present the confirmation screen.

### Medium Confidence

- OCR returns a plausible candidate but confidence is moderate or multiple candidates exist.
- The app should show a verification-oriented path, not automatic progression beyond controlled confirmation.

### Low Confidence

- OCR output is unstable, incomplete, or inconsistent.
- The system should advise rescan or manual search and should not attempt attendance marking.

Calibration note:

- Threshold values should be determined empirically using real OVGU cards, target devices, and representative exam lighting conditions.

## Fallback Mechanisms

- Fast rescan from the scan screen
- Manual search by name
- Manual lookup by matriculation number
- Optional torch usage in dim environments
- Camera guidance such as hold-still or reposition hints

## Performance Considerations

- Limit OCR frequency to prevent UI lag and battery drain.
- Use a constrained scan region where possible.
- Run OCR off the main UI thread.
- Avoid continuous full-frame OCR when a throttled frame strategy is sufficient.
- Optimize for rapid exact lookup rather than computationally expensive fuzzy search.

## Reliability Principle

The OCR subsystem should be treated as a support mechanism, not an autonomous decision-maker. In this domain, reliability means minimizing incorrect matches even if that occasionally requires an extra tap or a manual lookup.
