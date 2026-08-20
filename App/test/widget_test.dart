import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_application/features/auth/domain/auth_repository.dart';
import 'package:fitness_application/main.dart';
import 'package:fitness_application/theme/app_theme.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AuthUser?> authStateChanges() => const Stream.empty();

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('shows the application greeting for an authenticated user',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: HomeScreen(
          user: const AuthUser(
            id: 'user-1',
            email: 'ari@example.com',
            displayName: 'Ari',
          ),
          authRepository: _FakeAuthRepository(),
        ),
      ),
    );

    expect(find.text('Hello Ari'), findsOneWidget);
    final context = tester.element(find.text('Hello Ari'));
    expect(Theme.of(context).colorScheme.primary, const Color(0xFFBBF246));
    expect(Theme.of(context).scaffoldBackgroundColor, const Color(0xFF192126));
  });
}
