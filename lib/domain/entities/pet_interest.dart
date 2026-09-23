/// Interest a pet owner declares for their pet, as stored in the database
/// (`pets.interests`, a Postgres text array).
///
/// The column enforces membership with `CHECK (interests <@
/// ARRAY['socialization','breeding','adoption'])`, so [fromDb] throws rather
/// than silently dropping unknown values.
enum PetInterest {
  socialization('socialization'),
  breeding('breeding'),
  adoption('adoption');

  const PetInterest(this.dbValue);

  /// The value stored in the `pets.interests` array.
  final String dbValue;

  /// Resolves the [PetInterest] for a database [value], e.g. `'adoption'`.
  static PetInterest fromDb(String value) {
    for (final interest in values) {
      if (interest.dbValue == value) {
        return interest;
      }
    }
    throw FormatException('Unknown pet interest: "$value"');
  }

  /// The value to write back to the `pets.interests` array.
  String toDb() => dbValue;
}
