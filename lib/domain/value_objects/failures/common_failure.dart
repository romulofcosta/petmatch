/// Base class for all domain failures carried by [Result] (see
/// `domain/value_objects/result.dart`).
///
/// Every failure in the app extends [CommonFailure], giving the UI a uniform
/// shape to handle errors: a human-readable [message], a stable [code] for
/// analytics/decisions, and an [originalError] preserving the underlying
/// exception/stack trace for logging.
///
/// ## Hierarchy
///
/// ```text
/// CommonFailure
/// ├── UnknownFailure            (unmapped errors — failures/unknown_failure.dart)
/// ├── AuthFailure               (failures/auth_failure.dart)
/// │     ├── ValidationFailure · NetworkFailure · RateLimitedFailure
/// │     ├── UnauthorizedFailure · PermissionFailure · ServerFailure
/// └── PetFailure                (failures/pet_failure.dart)
///       ├── ValidationFailure · NetworkFailure · ServerFailure
///       └── PermissionFailure · NotFoundFailure
/// ```
///
/// ## Purpose
///
/// With `Result<T, CommonFailure>`-family types, Services, Repositories and
/// Use Cases return typed failures that are **values, not exceptions**. The
/// UI can match exhaustively: `PermissionFailure` → show rationale,
/// `NetworkFailure` → show retry, `UnknownFailure` → generic error + logs.
abstract class CommonFailure {
  const CommonFailure({
    required this.message,
    this.code = 'unknown',
    this.originalError,
  });

  /// Human-readable description of what failed.
  ///
  /// Prefer domain language (e.g. `'Não foi possível entrar'`) over
  /// technical details; technical context belongs in [originalError].
  final String message;

  /// Stable, machine-readable code for this failure type.
  ///
  /// Used for analytics, feature flags and UI branching. Defaults to
  /// `'unknown'` unless overridden by a concrete subtype.
  final String code;

  /// The underlying exception or error that caused this failure.
  ///
  /// Preserved for logging / diagnostics. May be `null` when the failure is
  /// purely a domain validation outcome (no exception involved).
  final Object? originalError;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}
