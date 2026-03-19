Map<String, String> parseSubtitle(String value) {
  // Check if it's a placeholder like "TBD"
  if (!RegExp(r'[\d.]').hasMatch(value)) {
    return {'numeric': value, 'unit': ''};
  }

  // Pattern to match: optional $ + number + optional suffix (like B, K, M) + optional space + optional unit (like USD, MXN)
  final pattern = RegExp(
    r'^(\$?[\d,]+(?:\.\d+)?[BKM]?)\s*(.*)$',
    caseSensitive: false,
  );
  final match = pattern.firstMatch(value.trim());

  if (match != null) {
    return {
      'numeric': match.group(1)?.trim() ?? value,
      'unit': match.group(2)?.trim() ?? '',
    };
  }

  return {'numeric': value, 'unit': ''};
}

Map<String, String> parseSubtitleOther(String value) {
  // Check if it's a placeholder like "TBD"
  if (!RegExp(r'[\d.]').hasMatch(value)) {
    return {'amount': value, 'unit': ''};
  }

  // Pattern to match: optional $ + number + optional suffix (like B, K, M) + optional space + optional unit (like USD, MXN)
  final pattern = RegExp(
    r'^(\$?[\d,]+(?:\.\d+)?[BKM]?)\s*(.*)$',
    caseSensitive: false,
  );
  final match = pattern.firstMatch(value.trim());

  if (match != null) {
    return {
      'amount': match.group(1)?.trim() ?? value,
      'unit': match.group(2)?.trim() ?? '',
    };
  }

  return {'amount': value, 'unit': ''};
}

int detectAndParseNumber(String input) {
  // Remove commas from the string
  String cleaned = input.replaceAll(',', '');

  // Try to parse as int
  int? result = int.tryParse(cleaned);

  if (result != null) {
    return result;
  } else {
    throw FormatException('Not a valid number: $input');
  }
}

bool isIntegerString(String str) {
  // Remove commas
  String cleaned = str.replaceAll(',', '');

  // Check if it's a valid number
  return int.tryParse(cleaned) != null;
}

bool isDoubleString(String str) {
  // Remove commas
  String cleaned = str.replaceAll(',', '');

  // Check if it's a valid number
  return double.tryParse(cleaned) != null;
}
