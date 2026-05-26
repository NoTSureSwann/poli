import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:klinik_app/features/auth/data/repositories/auth_repository_impl.dart';

@GenerateNiceMocks([MockSpec<SupabaseClient>(), MockSpec<GoTrueClient>()])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    
    // Setup mock SupabaseClient to return mock GoTrueClient
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    
    authRepository = AuthRepositoryImpl(mockSupabaseClient);
  });

  group('AuthRepositoryImpl', () {
    test('signIn should call Supabase auth.signInWithPassword', () async {
      final tEmail = 'test@example.com';
      final tPassword = 'password123';
      final tAuthResponse = AuthResponse(
        session: Session(
          accessToken: 'token', 
          expiresIn: 3600, 
          tokenType: 'bearer',
          user: User(
            id: '123',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: '2023-01-01',
          ),
        ),
      );

      when(mockGoTrueClient.signInWithPassword(email: tEmail, password: tPassword))
          .thenAnswer((_) async => tAuthResponse);

      final result = await authRepository.signIn(email: tEmail, password: tPassword);

      expect(result, equals(tAuthResponse));
      verify(mockGoTrueClient.signInWithPassword(email: tEmail, password: tPassword)).called(1);
    });
  });
}
