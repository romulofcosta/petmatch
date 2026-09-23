/// An immutable, validated email address.
///
/// Created only with a syntactically valid address — see
/// [Email.isValid]. The value is normalized to lowercase (the local part is
/// technically case-sensitive, but virtually every provider treats it as
/// case-insensitive; normalizing avoids auth mismatches like
/// `User@Mail.com` != `user@mail.com`).
class Email {
  /// Accepts addresses with a local part, a domain and a top-level domain,
  /// mirroring the app's legacy validator.
  static final RegExp _pattern =
      RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

  Email._(this.value);

  /// The normalized email address (trimmed, lowercase).
  final String value;

  /// Returns `true` when [candidate] is a syntactically valid email address.
  static bool isValid(String candidate) {
    final normalized = candidate.trim().toLowerCase();
    return _pattern.hasMatch(normalized);
  }

  /// Creates an [Email] from [candidate], throwing [FormatException] when it
  /// is invalid.
  ///
  /// Prefer this over repeated [isValid] checks: it guarantees the returned
  /// value is always valid.
  factory Email.parse(String candidate) {
    final normalized = candidate.trim().toLowerCase();
    if (!_pattern.hasMatch(normalized)) {
      throw FormatException('Invalid email address: "$candidate"');
    }
    return Email._(normalized);
  }

  /// The email address as a string (already normalized).
  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
