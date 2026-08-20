import 'dart:async';

import 'package:fitness_application/features/auth/domain/auth_repository.dart';
import 'package:fitness_application/features/auth/presentation/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._user);

  AuthUser? _user;
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<void> signInWithGoogle() async {
    _user = const AuthUser(id: 'user-1', displayName: 'Ari', email: 'ari@example.com');
    _controller.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}

void main() {
  testWidgets('shows Google sign-in when no Firebase user exists', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          repository: FakeAuthRepository(null),
          signedInBuilder: (context, user) => const Text('Signed in'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Signed in'), findsNothing);
  });

  testWidgets('shows protected content when Firebase user exists', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          repository: FakeAuthRepository(
            const AuthUser(id: 'user-1', displayName: 'Ari', email: 'ari@example.com'),
          ),
          signedInBuilder: (_, user) => Text('Welcome ${user.displayName}'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Welcome Ari'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
  });
}
