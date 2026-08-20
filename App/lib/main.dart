import 'package:flutter/material.dart';

import 'core/config/app_environment.dart';
import 'core/network/api_client.dart';
import 'core/network/http_get_request.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/home/data/api_home_repository.dart';
import 'features/home/domain/home_repository.dart';
import 'features/home/presentation/home_controller.dart';
import 'features/home/presentation/home_screen.dart';
import 'firebase_bootstrap.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  factory MyApp({
    AuthRepository? authRepository,
    HomeRepository? homeRepository,
    Key? key,
  }) {
    final resolvedAuthRepository = authRepository ?? FirebaseAuthRepository();
    final resolvedHomeRepository =
        homeRepository ?? _buildHomeRepository(resolvedAuthRepository);

    return MyApp._(
      authRepository: resolvedAuthRepository,
      homeRepository: resolvedHomeRepository,
      key: key,
    );
  }

  const MyApp._({
    required this._authRepository,
    required this._homeRepository,
    super.key,
  });

  final AuthRepository _authRepository;
  final HomeRepository _homeRepository;

  static HomeRepository _buildHomeRepository(AuthRepository authRepository) {
    return ApiHomeRepository(
      ApiClient(
        tokenProvider: authRepository.getIdToken,
        getRequest: createHttpGetRequest(
          baseUrl: AppEnvironment.instance.apiBaseUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Application',
      theme: AppTheme.dark(),
      home: AuthGate(
        repository: _authRepository,
        signedInBuilder: (_, user) => _AuthenticatedHomeScreen(
          key: ValueKey(user.id),
          repository: _homeRepository,
          onSignOut: _authRepository.signOut,
        ),
      ),
    );
  }
}

class _AuthenticatedHomeScreen extends StatefulWidget {
  const _AuthenticatedHomeScreen({
    required this.repository,
    required this.onSignOut,
    super.key,
  });

  final HomeRepository repository;
  final Future<void> Function() onSignOut;

  @override
  State<_AuthenticatedHomeScreen> createState() =>
      _AuthenticatedHomeScreenState();
}

class _AuthenticatedHomeScreenState extends State<_AuthenticatedHomeScreen> {
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(repository: widget.repository);
  }

  @override
  void didUpdateWidget(_AuthenticatedHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository == widget.repository) return;

    _controller.dispose();
    _controller = HomeController(repository: widget.repository);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(controller: _controller, onSignOut: widget.onSignOut);
  }
}
