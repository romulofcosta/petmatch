/// Biological sex of a pet, as stored in the database (`pets.sex`).
enum PetSex {
  male('male'),
  female('female');

  const PetSex(this.dbValue);

  /// The value stored in the `pets.sex` column.
  final String dbValue;

  /// Resolves the [PetSex] for a database [value], e.g. `'female'`.
  ///
  /// Throws [FormatException] for unknown values — never a default — since
  /// the column constrains values with `CHECK (sex IN ('male','female'))`.
  static PetSex fromDb(String value) {
    for (final sex in values) {
      if (sex.dbValue == value) {
        return sex;
      }
    }
    throw FormatException('Unknown pet sex: "$value"');
  }

  /// The value to write back to the `pets.sex` column.
  String toDb() => dbValue;
}
