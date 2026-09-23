/// Declarative error handling for the domain layer.
///
/// A [Result] is either a [Success] carrying a value `T`, or a [Failure]
/// carrying an error `E`. Failures are values, not control flow — using
/// [Result] eliminates silent `try/catch` in Services, Repositories,
/// Use Cases and ViewModels, and makes every error path explicit.
///
/// ## Why not exceptions?
///
/// Dart exceptions are for *exceptional* cases (programmer errors, unknown
/// runtime failures). Validation errors, "not found", "rate limited" and
/// "permission denied" are **expected outcomes** of a request. Modeling them
/// as [Result] failures makes them first-class values that the compiler
/// forces you to handle.
///
/// ## Usage
///
/// ```dart
/// // Define a failure hierarchy (see failures/):
/// sealed class ApiFailure { final String message; const ApiFailure(this.message); }
/// class NetworkFailure extends ApiFailure { const NetworkFailure() : super('network'); }
///
/// Result<String, ApiFailure> fetchName() {
///   final ok = true;
///   return ok ? const Success('Pet') : const Failure(NetworkFailure());
/// }
///
/// final name = fetchName().when(
///   success: (value) => 'Olá, $value!',
///   failure: (error) => 'Erro: ${error.message}',
/// );
/// ```
///
/// [when] is exhaustive, so the analyzer forces handling of both cases.
sealed class Result<T, E> {
  const Result();

  /// Matches this result, invoking [success] with the value when this is a
  /// [Success], or [failure] with the error when this is a [Failure].
  ///
  /// Exactly one callback runs per call.
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) {
    return switch (this) {
      Success<T, E>(:final value) => success(value),
      Failure<T, E>(:final error) => failure(error),
    };
  }

  /// Returns `true` when this is a [Success].
  bool get isSuccess => this is Success<T, E>;

  /// Returns `true` when this is a [Failure].
  bool get isFailure => this is Failure<T, E>;

  /// The success value, or `null` when this is a [Failure].
  T? get valueOrNull => switch (this) {
        Success<T, E>(:final value) => value,
        Failure<T, E>() => null,
      };

  /// The failure error, or `null` when this is a [Success].
  E? get errorOrNull => switch (this) {
        Success<T, E>() => null,
        Failure<T, E>(:final error) => error,
      };

  @override
  String toString() => when(
        success: (value) => 'Success($value)',
        failure: (error) => 'Failure($error)',
      );
}

/// A [Result] that represents a successful outcome with a [value].
final class Success<T, E> extends Result<T, E> {
  const Success(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      other is Success<T, E> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// A [Result] that represents a failed outcome with an [error].
///
/// Prefer a typed failure (e.g. `AuthFailure`, `PetFailure`) for [E]. Use the
/// failure hierarchy to enable precise UI decisions: `PermissionFailure` can
/// show a permission rationale, `NetworkFailure` a retry button, etc.
final class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);

  final E error;

  @override
  bool operator ==(Object other) =>
      other is Failure<T, E> && other.error == error;

  @override
  int get hashCode => error.hashCode;
}
