/// Reading a `entrepreneurs/{uid}/vendorDetails/{vendorId}` document.
///
/// Two things about those documents fail at runtime rather than compile time,
/// so they are handled here once instead of at every call site.

/// A numeric field, as a Dart double.
///
/// Firestore distinguishes integers from doubles on the wire, and vendor
/// documents have been written by two clients: the old form sent Dart doubles
/// (always `doubleValue`), while the Media API sends numbers parsed from JSON
/// and firebase-admin stores a whole one as an `integerValue`. So
/// `{from: 25000, to: 90000.5}` genuinely returns `{int, double}`, and
/// `Map<String, double>.from` on it throws
/// "type 'int' is not a subtype of type 'double' in type cast".
double vendorNumber(dynamic raw, {double fallback = 0}) {
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw) ?? fallback;
  return fallback;
}

/// The `budget` map, accepting int or double for either bound.
Map<String, double> vendorBudget(dynamic raw) {
  if (raw is! Map) return {'from': 0, 'to': 0};

  return {
    'from': vendorNumber(raw['from']),
    'to': vendorNumber(raw['to']),
  };
}

/// The `images` array as a list of plain maps. Tolerates a missing field.
List<Map<String, dynamic>> vendorImages(dynamic raw) {
  if (raw is! List) return const [];

  return raw
      .whereType<Map>()
      .map((entry) => Map<String, dynamic>.from(entry))
      .toList();
}

/// The image reference for one entry of `images`.
///
/// Two generations of writer, two field names, both still valid:
///
///  * `imagePath` — written since the R2 migration. An object key.
///  * `imageUrl`  — written before it. A Firebase Storage download URL.
///
/// The media resolver already tells a key from a URL, so the only job here is
/// finding whichever field this document carries.
String? vendorImageRef(Map<String, dynamic> entry) {
  final path = entry['imagePath'];
  if (path is String && path.trim().isNotEmpty) return path;

  final url = entry['imageUrl'];
  if (url is String && url.trim().isNotEmpty) return url;

  return null;
}

/// The caption for one entry of `images`.
String vendorImageCaption(Map<String, dynamic> entry) {
  final text = entry['text'];
  return text is String ? text : '';
}

/// A plain string field, or '' when absent — never a failed cast.
String vendorText(dynamic raw) => raw is String ? raw : '';
