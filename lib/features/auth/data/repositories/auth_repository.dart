import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../models/user_model.dart';

class AuthRepository implements AuthRepositoryInterface {
  final SupabaseClient _supabase;
  GoogleSignIn? _googleSignInInstance;

  GoogleSignIn get _googleSignIn {
    _googleSignInInstance ??= GoogleSignIn();
    return _googleSignInInstance!;
  }

  AuthRepository({
    SupabaseClient? supabaseClient,
  })  : _supabase = supabaseClient ?? Supabase.instance.client;

  @override
  UserEntity? get currentUser {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;
    return _userFromAuth(authUser);
  }

  @override
  Stream<AuthProfileResult> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      final authUser = event.session?.user;
      if (authUser == null) {
        return const AuthProfileResult(status: ProfileStatus.notFound);
      }

      try {
        return await _resolveProfile(authUser);
      } catch (e) {
        debugPrint('[AuthRepository] Erro ao resolver perfil: $e');
        return const AuthProfileResult(status: ProfileStatus.notFound);
      }
    });
  }

  Future<AuthProfileResult> _resolveProfile(User authUser) async {
    final profile = await getProfile(authUser.id);

    if (profile == null) {
      return const AuthProfileResult(status: ProfileStatus.notFound);
    }

    if (profile.isBanned) {
      return AuthProfileResult(status: ProfileStatus.banned, user: profile);
    }

    if (!profile.isActive) {
      return AuthProfileResult(status: ProfileStatus.inactive, user: profile);
    }

    return AuthProfileResult(status: ProfileStatus.valid, user: profile);
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AppAuthException(message: 'Erro ao fazer login');
      }

      return _userFromAuth(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException.fromSupabase(e);
    }
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required DateTime birthDate,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': displayName,
          'birth_date': birthDate.toIso8601String().split('T')[0],
        },
      );

      if (response.user == null) {
        throw const AppAuthException(message: 'Erro ao criar conta');
      }

      // A criação do perfil (users) acontece exclusivamente via a Edge Function
      // `create-profile`, durante o onboarding, que valida idade/localização,
      // calcula o geohash real e registra o LGPD consent_logs. Não grava aqui.
      return _userFromAuth(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException.fromSupabase(e);
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AppAuthException(message: 'Login com Google cancelado');
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw const AppAuthException(message: 'Erro ao autenticar com Google');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user == null) {
        throw const AppAuthException(message: 'Erro ao fazer login com Google');
      }

      return _userFromAuth(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException.fromSupabase(e);
    }
  }

  @override
  Future<UserEntity> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null) {
        throw const AppAuthException(message: 'Erro ao autenticar com Apple');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );

      if (response.user == null) {
        throw const AppAuthException(message: 'Erro ao fazer login com Apple');
      }

      return _userFromAuth(response.user!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException.fromSupabase(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _supabase.auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AppAuthException(message: 'Erro ao fazer logout');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'petmatch://reset-password',
      );
    } catch (e) {
      throw AppAuthException.fromSupabase(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: _supabase.auth.currentUser?.email,
      );
    } catch (e) {
      throw AppAuthException.fromSupabase(e);
    }
  }

  @override
  Future<UserEntity> createProfile({
    required String uid,
    required String displayName,
    required DateTime birthDate,
    required double latitude,
    required double longitude,
    required String city,
    required String state,
    Map<String, bool>? consents,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'create-profile',
        body: {
          'uid': uid,
          'display_name': displayName,
          'birth_date': birthDate.toIso8601String().split('T')[0],
          'latitude': latitude,
          'longitude': longitude,
          'city': city,
          'state': state,
          'consents': consents ??
              {
                'terms_of_use': true,
                'privacy_policy': true,
              },
        },
      );

      if (response.status != 201) {
        throw AppAuthException(
          message: response.data['error'] ?? 'Erro ao criar perfil',
        );
      }

      final profileData = response.data['user'];
      return UserModel.fromMap(profileData);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AppAuthException(message: 'Erro ao criar perfil: $e');
    }
  }

  @override
  Future<UserEntity?> getProfile(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (response != null) {
        final authUser = _supabase.auth.currentUser;
        if (authUser == null) return null;
        return UserModel.fromSupabaseUser(authUser.toJson(), response);
      }

      // Perfil inexistente: criação é responsabilidade da Edge Function
      // `create-profile` (via onboarding). Não insere direto aqui.
      return null;
    } catch (e) {
      debugPrint('[AuthRepository] Erro em getProfile: $e');
      return null;
    }
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phone,
    String? city,
    String? state,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) {
        throw const AppAuthException(message: 'Usuário não autenticado');
      }

      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (photoUrl != null) updates['photo_url'] = photoUrl;
      if (phone != null) updates['phone'] = phone;
      if (city != null) updates['city'] = city;
      if (state != null) updates['state'] = state;
      if (preferences != null) updates['preferences'] = preferences;

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();
        await _supabase.from('users').update(updates).eq('uid', uid);
      }
    } catch (e) {
      throw AppAuthException(message: 'Erro ao atualizar perfil');
    }
  }

  UserEntity _userFromAuth(User authUser) {
    final metadata = authUser.userMetadata ?? {};
    return UserModel(
      uid: authUser.id,
      email: authUser.email ?? '',
      displayName: metadata['full_name'] as String? ?? '',
      photoUrl: metadata['avatar_url'] as String?,
      phone: authUser.phone,
      birthDate: metadata['birth_date'] != null
          ? DateTime.parse(metadata['birth_date'] as String)
          : DateTime.now().subtract(const Duration(days: 365 * 25)),
      latitude: 0,
      longitude: 0,
      city: '',
      state: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
