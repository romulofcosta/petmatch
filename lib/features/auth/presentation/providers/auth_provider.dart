import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repositories/auth_repository_interface.dart';

final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  return AuthRepository();
});

final authStateProvider =
    StreamNotifierProvider<AuthNotifier, AuthProfileResult>(AuthNotifier.new);

class AuthNotifier extends StreamNotifier<AuthProfileResult> {
  late final AuthRepositoryInterface _repository;

  @override
  Stream<AuthProfileResult> build() {
    _repository = ref.read(authRepositoryProvider);
    return _repository.authStateChanges;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _repository.signInWithEmail(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required DateTime birthDate,
    String? phone,
  }) async {
    await _repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
      birthDate: birthDate,
      phone: phone,
    );
  }

  Future<void> signInWithGoogle() async {
    await _repository.signInWithGoogle();
  }

  Future<void> signInWithApple() async {
    await _repository.signInWithApple();
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }
}

final authLoadingProvider = StateProvider<bool>((ref) => false);

final authErrorProvider = StateProvider<String?>((ref) => null);
