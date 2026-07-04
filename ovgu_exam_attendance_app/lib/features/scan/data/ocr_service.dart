import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Result returned by [OcrService.extractMatricNumber].
class OcrResult {
  /// The raw full text extracted from the image (useful for debugging).
  final String rawText;

  /// The matric number candidate found in the text, or null if none detected.
  final String? matricNumber;

  const OcrResult({required this.rawText, required this.matricNumber});

  bool get found => matricNumber != null;
}

/// On-device OCR service backed by Google ML Kit Text Recognition.
///
/// Usage:
/// ```dart
/// final result = await OcrService.extractMatricNumber(imagePath);
/// if (result.found) {
///   // use result.matricNumber
/// }
/// ```
///
/// The service is stateless — each call creates and closes its own
/// [TextRecognizer] so callers don't need to manage lifecycle.
class OcrService {
  OcrService._(); // static-only class

  /// Primary pattern: looks for a German ID-card label followed by digits.
  ///   e.g. "Matrikel-Nr.: 123456"  or  "MatrikelNr 123456"
  static final _labelPattern = RegExp(
    r'[Mm]atrikel[-\s]?[Nn]r\.?:?\s*(\d{4,8})',
  );

  /// Fallback pattern: a standalone 6-digit number (typical OVGU matric length).
  /// Only used when the label pattern finds nothing.
  static final _standalonePattern = RegExp(r'\b(\d{6})\b');

  /// Extract text from [imagePath] and attempt to detect a matric number.
  ///
  /// Throws if ML Kit cannot process the image (e.g. file not found).
  static Future<OcrResult> extractMatricNumber(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognised = await recognizer.processImage(inputImage);
      final rawText = recognised.text;

      // Try label-based match first (most reliable)
      final labelMatch = _labelPattern.firstMatch(rawText);
      if (labelMatch != null) {
        return OcrResult(rawText: rawText, matricNumber: labelMatch.group(1));
      }

      // Fallback: first standalone 6-digit number in the text
      final standaloneMatch = _standalonePattern.firstMatch(rawText);
      if (standaloneMatch != null) {
        return OcrResult(
            rawText: rawText, matricNumber: standaloneMatch.group(1));
      }

      return OcrResult(rawText: rawText, matricNumber: null);
    } finally {
      await recognizer.close();
    }
  }
}
