// Shared CSV line splitting and header normalization for import flows.

String normalizeCsvHeader(String value) {
  return value.trim().toLowerCase().replaceAll(' ', '_');
}

List<String> parseCsvLine(String line) {
  final columns = <String>[];
  final current = StringBuffer();
  var inQuotes = false;

  for (var index = 0; index < line.length; index++) {
    final char = line[index];
    if (char == '"') {
      inQuotes = !inQuotes;
      continue;
    }

    if (char == ',' && !inQuotes) {
      columns.add(current.toString().trim());
      current.clear();
      continue;
    }

    current.write(char);
  }

  columns.add(current.toString().trim());
  return columns;
}
