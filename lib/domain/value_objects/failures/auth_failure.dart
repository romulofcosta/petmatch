import 'common_failure.dart';

/// Failure hierarchy for the authentication domain.
///
/// All auth errors extend [AuthFailure], which itself extends
/// [CommonFailure]. Concrete subtypes enable exhaustive handling in the UI
/// via `result.when(failure: ...)`:
///
/// - [AuthValidationFailure]  → invalid form input (email/password format)
/// - [AuthNetworkFailure]     → connection/network problem
/// - [AuthServerFailure]      → backend returned an error
/// - [AuthRateLimitedFailure] → too many requests
/// - [AuthUnauthorizedFailure]→ invalid credentials / not allowed
/// - [AuthPermissionFailure]  → OS permission denied
///
/// Subtypes are prefixed with `Auth` so the class names do not collide with
/// `PetFailure` subtypes (e.g. `PetValidationFailure`).
sealed class AuthFailure extends CommonFailure {
  const AuthFailure({
    required super.message,
    required super.code,
    super.originalError,
  });
}

/// Invalid authentication input (e.g. malformed email or weak password).
final class AuthValidationFailure extends AuthFailure {
  const AuthValidationFailure({
    super.message = 'Dados de autenticação inválidos.',
    super.originalError,
  }) : super(code: 'auth_validation');
}

/// Network problem while reaching the auth backend.
final class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure({
    super.message = 'Não foi possível conectar. Verifique sua internet.',
    super.originalError,
  }) : super(code: 'auth_network');
}

/// The auth backend returned an unexpected/user-visible error.
final class AuthServerFailure extends AuthFailure {
  const AuthServerFailure({
    super.message = 'Ocorreu um erro no servidor. Tente novamente.',
    super.originalError,
  }) : super(code: 'auth_server');
}

/// Too many authentication attempts; the backend is rate limiting.
final class AuthRateLimitedFailure extends AuthFailure {
  const AuthRateLimitedFailure({
    super.message = 'Muitas tentativas. Aguarde alguns minutos.',
    super.originalError,
  }) : super(code: 'auth_rate_limited');
}

/// Invalid credentials or insufficient permission to authenticate.
final class AuthUnauthorizedFailure extends AuthFailure {
  const AuthUnauthorizedFailure({
    super.message = 'E-mail ou senha incorretos.',
    super.originalError,
  }) : super(code: 'auth_unauthorized');
}

/// OS-level permission denied (e.g. geolocation used during sign-up).
final class AuthPermissionFailure extends AuthFailure {
  const AuthPermissionFailure({
    super.message = 'Permissão necessária não concedida.',
    super.originalError,
  }) : super(code: 'auth_permission');
}
