import 'package:flutter/material.dart';

import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'firebase_bootstrap.dart';
import 'package:fitness_application/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({AuthRepository? authRepository, super.key})
      : _authRepository = authRepository ?? FirebaseAuthRepository();

  final AuthRepository _authRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Application',
      theme: AppTheme.dark(),
      home: AuthGate(
        repository: _authRepository,
        signedInBuilder: (_, user) => HomeScreen(
          user: user,
          authRepository: _authRepository,
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.user,
    required this.authRepository,
    super.key,
  });

  final AuthUser user;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: authRepository.signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Hello ${user.displayName ?? user.email}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
