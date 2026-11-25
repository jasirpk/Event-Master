/// Field readers for an `entrepreneurs/{uid}` document.
///
/// Every field on this document is optional. The Media API saves a profile
/// with `update()` carrying only the keys the request named, so anything the
/// owner has never filled in is absent rather than empty, and clearing the
/// website deletes the field outright (`FieldValue.delete()`). Absence is the
/// designed state, not corruption.
///
/// Reading such a field straight into a non-nullable `String` is therefore a
/// cast that can fail at any time — which is what
/// `type 'Null' is not a subtype of type 'String'` was. These readers do the
/// narrowing once, in one place, so no screen has to guess.
///
/// The counterpart for vendor documents is `vendorText` in
/// `vendor_document.dart`; this file keeps the same shape for profiles.
library;

/// A text field, or '' when it is absent.
String profileText(dynamic raw) {
  if (raw is String) return raw;
  if (raw == null) return '';

  // Documents written before the Media API owned this collection came
  // straight from the app and can hold a number where a string is expected —
  // a phone number, typically. Showing it beats silently dropping it.
  return raw.toString();
}

/// An optional text field: null when the field is absent *or* blank.
///
/// Firestore has no "blank" state for a string — it is set or it is not — but
/// a legacy document can still hold ''. Collapsing both onto null lets a
/// caller decide with one check whether there is anything to show, instead of
/// rendering a label with nothing after it.
String? profileOptionalText(dynamic raw) {
  final text = profileText(raw).trim();
  return text.isEmpty ? null : text;
}

/// A list-of-maps field (`links`, `images`), or [] when it is absent.
///
/// `List<Map<String, dynamic>>.from(raw)` threw outright on an absent field
/// and on any entry that was not a map. An entry that is not a map is skipped
/// here, so one malformed row costs its own line rather than the screen.
List<Map<String, dynamic>> profileMapList(dynamic raw) {
  if (raw is! Iterable) return const [];

  return raw
      .whereType<Map>()
      // Not Map<String, dynamic>.from: that is itself a cast, and it throws on
      // a key that is not a String. Rebuilding the keys cannot fail.
      .map((entry) => entry.map((key, value) => MapEntry('$key', value)))
      .toList();
}
