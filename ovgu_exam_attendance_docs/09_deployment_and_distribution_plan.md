# 9. Deployment & Distribution Plan

## Deployment Strategy

The recommended initial deployment model is institution-controlled distribution on approved Android devices. This aligns with the Android-first technical target and allows OVGU to standardize hardware, permissions, and support procedures before considering broader rollout.

## Distribution Options

Recommended order:

1. Direct APK distribution by OVGU IT to managed devices.
2. Mobile Device Management deployment if OVGU uses centralized device administration.
3. Private internal app distribution channel if institutional infrastructure supports it.

Later iOS options:

- TestFlight for pilot evaluation
- institutional iOS deployment for production use

## Installation Procedure

1. Install the approved application build on the exam device.
2. Grant camera and local file access permissions as required.
3. Import the **correct** participant CSV before the exam begins (MVP has no separate named session—wrong file is operator error).
4. Confirm that the device is sufficiently charged and configured for offline operation.
5. Run check-in with scanning and/or manual search; use **Export** when finished to obtain **present/absent** CSV.

**Post-MVP:** named exam sessions and session verification steps may be added for multi-exam device reuse.

## Operational Preparation Checklist

- device battery charged
- participant CSV imported
- camera permission granted
- storage access or document picker available for import and export
- torch functionality checked if needed
- export destination procedure known to exam staff

## Permissions Required

Essential permissions:

- camera
- file access or document picker access for CSV import and export

Permissions to avoid:

- internet on Android production build
- microphone
- contacts
- location
- background location
- unnecessary broad storage access

## Device Compatibility

Recommended baseline profile:

- Android 10 or newer
- reliable autofocus rear camera
- at least 3 GB RAM preferred
- sufficient storage for local database and export files
- battery capacity suitable for a full exam session

Operational recommendation:

- Standardize on a small set of approved device models to reduce OCR variability and simplify support.

## Release Management

- Maintain separate build variants for development and production if testing tools require additional capabilities.
- Production builds should undergo a privacy and permission review before release.
- A release checklist should verify offline operation, export behavior, and absence of unintended network dependencies.
