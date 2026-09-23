import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:petmatch/features/auth/data/repositories/auth_repository.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrue extends Mock implements GoTrueClient {}

class _MockFunctions extends Mock implements FunctionsClient {}

void main() {
  late _MockSupabaseClient supabase;
  late _MockGoTrue auth;
  late _MockFunctions functions;

  final user = const User(
    id: 'u1',
    appMetadata: const {},
    userMetadata: const {
      'full_name': 'Rex Tutor',
      'birth_date': '1990-05-05',
    },
    aud: 'authenticated',
    email: 'rex@example.com',
    phone: null,
    createdAt: '2026-01-01T00:00:00Z',
  );

  setUp(() {
    supabase = _MockSupabaseClient();
    auth = _MockGoTrue();
    functions = _MockFunctions();

    when(() => supabase.auth).thenReturn(auth);
    when(() => supabase.functions).thenReturn(functions);
    when(() => auth.currentUser).thenReturn(user);
  });

  group('signUpWithEmail', () {
    test('signs up via Supabase Auth and does NOT insert a profile row '
        'or call the SQL RPC', () async {
      final repo = AuthRepository(supabaseClient: supabase);

      when(() => auth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => AuthResponse(user: user));

      final result = await repo.signUpWithEmail(
        email: 'rex@example.com',
        password: 'secret123',
        displayName: 'Rex Tutor',
        birthDate: DateTime(1990, 5, 5),
      );

      expect(result.uid, 'u1');
      // Profile creation must NOT happen here: no direct insert, no RPC.
      verifyNever(() => supabase.from(any()));
      verifyNever(() => supabase.rpc(any(), params: any(named: 'params')));
    });
  });

  group('createProfile', () {
    test('routes to the create-profile Edge Function (no RPC / no insert)',
        () async {
      final repo = AuthRepository(supabaseClient: supabase);

      final userMap = <String, dynamic>{
        'uid': 'u1',
        'email': 'rex@example.com',
        'display_name': 'Rex Tutor',
        'birth_date': '1990-05-05',
        'city': 'SAO PAULO',
        'state': 'SP',
        'country': 'BR',
        'location': {'type': 'Point', 'coordinates': [-46.6333, -23.5505]},
        'is_active': true,
        'is_verified': false,
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      };

      when(() => functions.invoke(
            'create-profile',
            body: any(named: 'body'),
          )).thenAnswer((_) async => FunctionResponse(
        status: 201,
        data: <String, dynamic>{'user': userMap},
      ));

      final result = await repo.createProfile(
        uid: 'u1',
        displayName: 'Rex Tutor',
        birthDate: DateTime(1990, 5, 5),
        latitude: -23.5505,
        longitude: -46.6333,
        city: 'SAO PAULO',
        state: 'SP',
      );

      expect(result.uid, 'u1');
      final body = verify(() => functions.invoke(
            'create-profile',
            body: captureAny(named: 'body'),
          )).captured.single as Map<String, dynamic>;
      // Consent is delegated to the Edge Function (which writes consent_logs).
      expect(body['consents'], isNotNull);
      verifyNever(() => supabase.from(any()));
      verifyNever(() => supabase.rpc(any(), params: any(named: 'params')));
    });
  });
}
