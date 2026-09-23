import 'common_failure.dart';

/// Failure hierarchy for the pets domain.
///
/// All pet errors extend [PetFailure], which itself extends [CommonFailure].
/// Concrete subtypes enable exhaustive handling in the UI via
/// `result.when(failure: ...)`:
///
/// - [PetValidationFailure]   → invalid pet form input
/// - [PetNetworkFailure]      → connection/network problem
/// - [PetServerFailure]       → backend returned an error
/// - [PetPermissionFailure]   → OS permission denied (e.g. geolocation)
/// - [PetNotFoundFailure]     → pet was not found / already removed
///
/// Subtypes are prefixed with `Pet` so the class names do not collide with
/// `AuthFailure` subtypes (e.g. `AuthValidationFailure`).
sealed class PetFailure extends CommonFailure {
  const PetFailure({
    required super.message,
    required super.code,
    super.originalError,
  });
}

/// Invalid pet-related input (e.g. missing name, invalid birth date).
final class PetValidationFailure extends PetFailure {
  const PetValidationFailure({
    super.message = 'Dados do pet inválidos. Revise as informações.',
    super.originalError,
  }) : super(code: 'pet_validation');
}

/// Network problem while reaching the pets backend.
final class PetNetworkFailure extends PetFailure {
  const PetNetworkFailure({
    super.message = 'Não foi possível conectar. Verifique sua internet.',
    super.originalError,
  }) : super(code: 'pet_network');
}

/// The pets backend returned an unexpected/user-visible error.
final class PetServerFailure extends PetFailure {
  const PetServerFailure({
    super.message = 'Ocorreu um erro no servidor. Tente novamente.',
    super.originalError,
  }) : super(code: 'pet_server');
}

/// OS-level permission denied (e.g. geolocation required to create a pet).
final class PetPermissionFailure extends PetFailure {
  const PetPermissionFailure({
    super.message = 'Permissão de localização necessária.',
    super.originalError,
  }) : super(code: 'pet_permission');
}

/// The requested pet does not exist or was removed.
final class PetNotFoundFailure extends PetFailure {
  const PetNotFoundFailure({
    super.message = 'Pet não encontrado.',
    super.originalError,
  }) : super(code: 'pet_not_found');
}
