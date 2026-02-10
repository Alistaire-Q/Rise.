import 'dart:ui' as ui;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ReceiptData {
  final double? amount;
  final String? rawAmountString; // NEW
  final String? merchant;
  final DateTime? date;

  ReceiptData({this.amount, this.rawAmountString, this.merchant, this.date});
}

class OcrService {
  final _picker = ImagePicker();
  // Menggunakan script Latin untuk membaca tulisan umum
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // Fungsi baru: Langsung buka kamera -> Foto -> Deteksi Angka
  Future<ReceiptData?> scanReceipt() async {
    try {
      // 1. Buka Kamera
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return null;
      final inputImage = InputImage.fromFilePath(photo.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 3. Analisa teks yang dikenali untuk menemukan jumlah, pedagang, dan tanggal
      final result = _analyzeReceipt(recognizedText);
      return result;
    } catch (e) {
      print('Error scanning receipt: $e');
      return null;
    }
  }

  // Analisa teks yang dikenali untuk menemukan informasi struk
  ReceiptData? _analyzeReceipt(RecognizedText recognizedText) {
  // Build lines and full text
  List<String> lines = [];
  for (TextBlock block in recognizedText.blocks) {
    for (TextLine line in block.lines) {
      String text = line.text.trim();
      if (text.isEmpty) continue;
      lines.add(text);
    }
  }
  final fullText = recognizedText.text ?? lines.join('\n');

  // 1) Prefer the robust helper that searches keywords & normalizes Indonesian formats
  final double helperAmount = ReceiptOcrHelper.extractTotalAmount(fullText);
  if (helperAmount > 0) {
    // Find the raw token that produced helperAmount (best-effort)
    String? rawToken;
    final tokenRegex = RegExp(r'(?:Rp|IDR)?\s*[\d\.,]+', caseSensitive: false);
    for (final m in tokenRegex.allMatches(fullText)) {
      final raw = m.group(0)!;
      final normalized = ReceiptOcrHelper.normalizeNumberString(raw);
      if (normalized.isEmpty) continue;
      final parsed = double.tryParse(normalized);
      if (parsed != null && (parsed - helperAmount).abs() < 0.0001) {
        rawToken = raw.trim();
        break;
      }
    }
    String? merchant = _extractMerchant(lines);
    DateTime? date = _extractDate(lines);
    return ReceiptData(amount: helperAmount, rawAmountString: rawToken, merchant: merchant, date: date);
  }

  // 2) Fallback to previous heuristics (keyword-first, then sum items, then numeric candidates)
  double? total = _extractTotalByKeyword(lines);
  total ??= _sumItemLines(lines);
  if (total == null) {
    final candidates = <double>[];
    for (final l in lines) {
      final nums = _extractNumbersFromText(l);
      if (nums.isNotEmpty) candidates.addAll(nums);
    }
    if (candidates.isNotEmpty) {
      candidates.sort();
      total = candidates.lastWhere((c) => c < 10000000, orElse: () => candidates.last);
    }
  }

  // Debug fallback info
  debugPrint('OCR full text (fallback):\\n$fullText');
  debugPrint('Fallback detected total -> ${total ?? 0.0}');
  String? merchant = _extractMerchant(lines);
  DateTime? date = _extractDate(lines);

  return ReceiptData(amount: total, rawAmountString: null, merchant: merchant, date: date);
}

  // Heuristik: pilih baris pertama yang bukan numerik dan kapital sebagai nama pedagang
  String? _extractMerchant(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      String t = lines[i].trim();
      if (RegExp(r'\d').hasMatch(t)) continue;
      if (t.length < 3 || (t.length > 60 && t.split(' ').length < 2)) continue;
      return t;
    }
    return null;
  }

  // Coba beberapa pola tanggal umum
  DateTime? _extractDate(List<String> lines) {
    final patterns = [
      RegExp(r'(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})'), // 12/05/2024 atau 12-05-24
      RegExp(r'(\d{4}[\/\-]\d{1,2}[\/\-]\d{1,2})'), // 2024-05-12
      RegExp(r'(\d{1,2}\s+[A-Za-z]{3,}\s+\d{4})'), // 12 Mei 2024
      RegExp(r'([A-Za-z]{3,}\s+\d{1,2},\s+\d{4})'), // Mei 12, 2024
    ];

    for (String line in lines) {
      for (final p in patterns) {
        final m = p.firstMatch(line);
        if (m != null) {
          String found = m.group(0)!;
          try {
            // Normalisasi pemisah
            String normalized = found.replaceAll('-', '/').replaceAll(',', '');
            // Coba dd/mm/yyyy atau yyyy/mm/dd
            List<String> parts = normalized.split(RegExp(r'[\/\s]+'));
            if (parts.length >= 3) {
              int a = int.tryParse(parts[0]) ?? 0;
              int b = int.tryParse(parts[1]) ?? 0;
              int c = int.tryParse(parts[2]) ?? 0;
              // deteksi yyyy-mm-dd
              if (c < 100) {
                // tahun dua digit -> asumsikan 2000+
                c += 2000;
              }
              DateTime dt;
              if (a > 31) {
                // mungkin yyyy/mm/dd
                dt = DateTime(a, b, c);
              } else {
                // asumsikan dd/mm/yyyy
                dt = DateTime(c, a, b);
              }
              return dt;
            }
          } catch (_) { /* abaikan kesalahan parsing */ }
        }
      }
    }
    return null;
  }

  // --- NEW HELPERS BELOW ---

  // Find totals by looking for common keywords like "total", "subtotal", "payment"
  double? _extractTotalByKeyword(List<String> lines) {
    final keywords = RegExp(r'\b(total|subtotal|amount due|payment|grand total|paid|amount)\b', caseSensitive: false);
    // Search from bottom up to prefer footer totals
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      if (keywords.hasMatch(line)) {
        final nums = _extractNumbersFromText(line);
        if (nums.isNotEmpty) {
          // prefer last numeric token in the line
          return nums.last;
        }
        // Sometimes the amount is on the next line after the keyword
        if (i + 1 < lines.length) {
          final nextNums = _extractNumbersFromText(lines[i + 1]);
          if (nextNums.isNotEmpty) return nextNums.last;
        }
      }
    }
    return null;
  }

  // Sum lines that look like item rows: text followed by a monetary value at line end
  double? _sumItemLines(List<String> lines) {
    double sum = 0;
    bool found = false;
    final itemPriceEndPattern = RegExp(r'(\d{1,3}(?:[.,]\d{3})+|\d{1,7})(?!\S)\s*$', multiLine: false);
    for (final line in lines) {
      // Skip lines that contain typical non-item info
      if (RegExp(r'\b(total|subtotal|payment|change|tax|debit|credit|visa|mastercard)\b', caseSensitive: false).hasMatch(line)) {
        continue;
      }
      final m = itemPriceEndPattern.firstMatch(line);
      if (m != null) {
        final nums = _extractNumbersFromText(m.group(0)!);
        if (nums.isNotEmpty) {
          sum += nums.last;
          found = true;
        }
      }
    }
    return found ? sum : null;
  }

  // Extract numeric tokens from a line, with normalization and filters to avoid timestamps/ids
  List<double> _extractNumbersFromText(String text) {
    final results = <double>[];
    // match numbers with thousand separators or plain up to 7 digits (avoid huge IDs)
    final regex = RegExp(r'(\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?|\d{1,7}(?:[.,]\d{2})?)');
    for (final m in regex.allMatches(text)) {
      String raw = m.group(0)!;
      // skip if seems like time e.g., 16:33 or date fragments with ':' present
      if (raw.contains(':')) continue;
      // Use shared normalizer
      final normalized = ReceiptOcrHelper.normalizeNumberString(raw);
      if (normalized.isEmpty) continue;
      final digitsOnly = normalized.replaceAll('.', '');
      if (digitsOnly.length > 7 && !(raw.contains('.') || raw.contains(','))) {
        continue;
      }
      try {
        final val = double.parse(normalized);
        if (val > 0 && val < 100000000) {
          results.add(val);
        }
      } catch (_) {
        continue;
      }
    }
    return results;
  }

  // REMOVE the instance method `double extractTotalAmount(String text) { ... }` if present

  // ADD: new static helper class for receipt amount extraction
  

  // Penting: Tutup recognizer saat aplikasi dimatikan/tidak dipakai untuk hemat memori
  void dispose() {
    _textRecognizer.close();
  }
}

class ReceiptOcrHelper {
  // Static helper to extract the probable total from raw OCR text.
  // Strategy: iterate bottom-to-top, look for Indonesian keywords,
  // clean numeric tokens (remove Rp/IDR, dots as thousands, comma as decimal),
  // validate and ignore phone numbers/years/IDs, return largest plausible amount.
  static double extractTotalAmount(String text) {
    if (text.trim().isEmpty) return 0.0;
    final keywords = ['total', 'jumlah', 'bayar', 'tagihan', 'grand'];
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    List<double> numsFromLine(String line) {
      final List<double> res = [];
      final tokenRegex = RegExp(r'(?:Rp|IDR)?\s*[\d\.,]+', caseSensitive: false);
      for (final m in tokenRegex.allMatches(line)) {
        String raw = m.group(0)!;
        // Use robust normalizer
        final normalized = normalizeNumberString(raw);
        if (normalized.isEmpty) continue;
        final digitsOnly = normalized.replaceAll('.', '');
        // Ignore phone-like numbers starting with 08 and long
        if (digitsOnly.startsWith('08') && digitsOnly.length > 10) continue;
        // Ignore years like 2023-2100
        if (digitsOnly.length == 4) {
          final y = int.tryParse(digitsOnly);
          if (y != null && y >= 1900 && y <= 2100) continue;
        }
        if (normalized.isEmpty) continue;
        final value = double.tryParse(normalized);
        if (value != null && value > 0 && value < 100000000) {
          res.add(value);
        }
      }
      return res;
    }

    // Bottom-up keyword search
    for (int i = lines.length - 1; i >= 0; i--) {
      final l = lines[i];
      final lower = l.toLowerCase();
      if (keywords.any((k) => lower.contains(k))) {
        final same = numsFromLine(l);
        if (same.isNotEmpty) return same.last;
        if (i + 1 < lines.length) {
          final next = numsFromLine(lines[i + 1]);
          if (next.isNotEmpty) return next.last;
        }
      }
    }
    // Fallback: gather all numeric candidates and return the largest plausible
    final all = <double>[];
    for (final ln in lines) {
      all.addAll(numsFromLine(ln));
    }
    if (all.isEmpty) return 0.0;
    all.sort();
    return all.last;
  }

  // NEW: robust normalization for numeric tokens (handles ., comma as thousands/decimal heuristically)
  static String normalizeNumberString(String raw) {
    // keep only digits and separators
    String s = raw.replaceAll(RegExp(r'[^0-9\.,]'), '');
    if (s.isEmpty) return s;

    final hasDot = s.contains('.');
    final hasComma = s.contains(',');

    if (hasDot && hasComma) {
      // Cases:
      // "1.234,56" -> dot thousands, comma decimal -> remove dots, replace comma with dot => 1234.56
      // "1,234.56" -> comma thousands, dot decimal -> remove commas => 1234.56
      final lastComma = s.lastIndexOf(',');
      final lastDot = s.lastIndexOf('.');
      if (lastComma > lastDot) {
        // comma appears later -> treat comma as decimal
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // dot appears later -> treat dot as decimal
        s = s.replaceAll(',', '');
      }
    } else if (hasComma) {
      // Only comma present. Determine if comma is thousands or decimal by digits after last comma.
      final lastComma = s.lastIndexOf(',');
      final digitsAfter = s.length - lastComma - 1;
      if (digitsAfter == 3) {
        // likely thousands separator (e.g. "43,500") -> remove commas
        s = s.replaceAll(',', '');
      } else {
        // likely decimal separator (e.g. "43,50") -> convert to dot
        s = s.replaceAll(',', '.');
      }
    } else if (hasDot) {
      // Only dot present. If exactly 3 digits after last dot, likely thousands sep -> remove dots.
      final lastDot = s.lastIndexOf('.');
      final digitsAfter = s.length - lastDot - 1;
      if (digitsAfter == 3) {
        s = s.replaceAll('.', '');
      } else {
        // keep dot as decimal
      }
    }

    // final cleanup: leave only digits and a single dot (if present)
    s = s.replaceAll(RegExp(r'[^0-9.]'), '');
    return s;
  }

  // NEW: extract total from RecognizedText but only consider text inside roi (image coordinates).
  // If roi is null uses full text.
  static double extractTotalFromRecognizedText(RecognizedText recognizedText, [ui.Rect? roi]) {
    if (recognizedText.text.trim().isEmpty) return 0.0;

    // If no ROI, just run normal text extraction on full text
    if (roi == null) {
      return extractTotalAmount(recognizedText.text);
    }

    // Collect lines whose bounding boxes overlap the roi
    final filteredLines = <String>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final bb = line.boundingBox;
        // Overlap test between roi and detected line bbox (both in image coordinates)
        if (roi.overlaps(bb)) {
          filteredLines.add(line.text);
        }
      }
    }

    if (filteredLines.isNotEmpty) {
      final filteredText = filteredLines.join('\n');
      final amt = extractTotalAmount(filteredText);
      if (amt > 0) return amt;
    }

    // Fallback: try full text if nothing plausible found in ROI
    return extractTotalAmount(recognizedText.text);
  }
}

