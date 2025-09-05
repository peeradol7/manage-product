class StringCleaningService {
  static String cleanText(String? input) {
    if (input == null || input.trim().isEmpty) {
      return '';
    }

    final noSpaces = input.replaceAll(' ', '');

    return cleanToLettersOnly(noSpaces);
  }

  static String cleanToLettersOnly(String? input) {
    if (input == null || input.trim().isEmpty) {
      return '';
    }

    final buffer = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final codeUnit = char.codeUnitAt(0);

      if ((codeUnit >= 0x41 && codeUnit <= 0x5A) ||
          (codeUnit >= 0x61 && codeUnit <= 0x7A) ||
          (codeUnit >= 0x0E00 && codeUnit <= 0x0E7F)) {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  static String cleanSearchTerm(String? searchTerm) {
    if (searchTerm == null || searchTerm.trim().isEmpty) {
      return '';
    }

    final trimmed = searchTerm.trim();

    // Remove all spaces and keep letters and numbers while preserving order
    final buffer = StringBuffer();

    for (int i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      final codeUnit = char.codeUnitAt(0);

      if ((codeUnit >= 0x41 && codeUnit <= 0x5A) || // A-Z
          (codeUnit >= 0x61 && codeUnit <= 0x7A) || // a-z
          (codeUnit >= 0x30 && codeUnit <= 0x39) || // 0-9
          (codeUnit >= 0x0E00 && codeUnit <= 0x0E7F)) {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  static bool isValidText(String? input) {
    if (input == null || input.trim().isEmpty) {
      return false;
    }

    final cleaned = cleanToLettersOnly(input);
    return cleaned.isNotEmpty;
  }

  static String previewCleanedText(String? input) {
    if (input == null || input.trim().isEmpty) {
      return '';
    }

    final cleaned = cleanText(input);
    return cleaned.isEmpty ? '[ไม่มีตัวอักษรที่ถูกต้อง]' : cleaned;
  }
}
