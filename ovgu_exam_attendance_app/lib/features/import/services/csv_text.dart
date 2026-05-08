String normalizeCsvHeader(String value) {
  return value.trim().toLowerCase().replaceAll(' ', '_');
}

String detectDelimiter(String headerLine) {
  if (parseCsvLine(headerLine, ',').length > 1) return ',';
  if (parseCsvLine(headerLine, ';').length > 1) return ';';
  return '\t';
}

List<String> parseCsvLine(String line, [String delimiter = ',']) {
  final columns = <String>[];
  final current = StringBuffer();
  var inQuotes = false;

  for (var index = 0; index < line.length; index++) {
    final char = line[index];

    if (char == '"') {
      inQuotes = !inQuotes;
      continue;
    }

    if (!inQuotes && line.startsWith(delimiter, index)) {
      columns.add(current.toString().trim());
      current.clear();
      index += delimiter.length - 1;
      continue;
    }

    current.write(char);
  }

  columns.add(current.toString().trim());
  return columns;
}
