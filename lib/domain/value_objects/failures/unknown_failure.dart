import 'common_failure.dart';

/// Failure used when an error does not map to any known domain failure.
///
/// Prefer specific subtypes (`AuthFailure`, `PetFailure`) whenever possible;
/// [UnknownFailure] is the fallback for unmapped/unexpected errors. It still
/// preserves [message] and the original [CommonFailure.originalError] so
/// unexpected paths remain diagnosable in logs.
class UnknownFailure extends CommonFailure {
  const UnknownFailure({
    required super.message,
    super.originalError,
  }) : super(code: 'unknown_error');

  /// Convenience factory wrapping a caught [error] into an [UnknownFailure],
  /// keeping the original object for logging.
  factory UnknownFailure.fromError(
    Object error, {
    String message = 'Erro inesperado. Tente novamente.',
  }) {
    return UnknownFailure(
      message: message,
      originalError: error,
    );
  }
}
