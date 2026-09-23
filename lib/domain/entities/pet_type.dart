/// Species of a pet, as stored in the database (`pets.type`).
///
/// The enum keeps a single source of truth for the two supported values,
/// replacing the legacy ad-hoc strings (`'dog'`/`'cat'`) scattered through
/// models, entities and widgets.
enum PetType {
  dog('dog'),
  cat('cat');

  const PetType(this.dbValue);

  /// The value stored in the `pets.type` column.
  final String dbValue;

  /// Resolves the [PetType] for a database [value], e.g. `'dog'`.
  ///
  /// Throws [FormatException] for unknown values so callers never fall back
  /// to a silent default that could mask schema drift (the column already
  /// constrains values via `CHECK (type IN ('dog','cat'))`).
  static PetType fromDb(String value) {
    for (final type in values) {
      if (type.dbValue == value) {
        return type;
      }
    }
    throw FormatException('Unknown pet type: "$value"');
  }

  /// The value to write back to the `pets.type` column.
  String toDb() => dbValue;
}
