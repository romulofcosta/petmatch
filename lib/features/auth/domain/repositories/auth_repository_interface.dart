import '../entities/user_entity.dart';

/// Estados possíveis do perfil do usuário no banco de dados.
enum ProfileStatus {
  /// Perfil encontrado e válido.
  valid,

  /// Perfil não encontrado na tabela users (cadastro incompleto).
  notFound,

  /// Perfil existe mas está banido.
  banned,

  /// Perfil existe mas está desativado.
  inactive,

  /// Perfil foi soft-deleted (deleted_at preenchido).
  deleted,
}

class AuthProfileResult {
  final ProfileStatus status;
  final UserEntity? user;

  const AuthProfileResult({required this.status, this.user});

  bool get isAuthenticated => status == ProfileStatus.valid && user != null;
}

abstract class AuthRepositoryInterface {
  UserEntity? get currentUser;
  Stream<AuthProfileResult> get authStateChanges;
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required DateTime birthDate,
    String? phone,
  });
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithApple();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> sendEmailVerification();
  Future<UserEntity> createProfile({
    required String uid,
    required String displayName,
    required DateTime birthDate,
    required double latitude,
    required double longitude,
    required String city,
    required String state,
    Map<String, bool>? consents,
  });
  Future<UserEntity?> getProfile(String uid);
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phone,
    String? city,
    String? state,
    Map<String, dynamic>? preferences,
  });
}
