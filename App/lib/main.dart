import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  final preferences = await SharedPreferences.getInstance();
  runApp(MyApp(themeController: ThemeController.fromPreferences(preferences)));
}

class MyApp extends StatefulWidget {
  factory MyApp({
    AuthRepository? authRepository,
    HomeRepository? homeRepository,
    ThemeController? themeController,
    Key? key,
  }) {
    final resolvedAuthRepository = authRepository ?? FirebaseAuthRepository();
    final resolvedHomeRepository =
        homeRepository ?? _buildHomeRepository(resolvedAuthRepository);

    return MyApp._(
      authRepository: resolvedAuthRepository,
      homeRepository: resolvedHomeRepository,
      themeController: themeController ?? ThemeController.inMemory(),
      key: key,
    );
  }

  const MyApp._({
    required this._authRepository,
    required this._homeRepository,
    required this._themeController,
    super.key,
  });

  final AuthRepository _authRepository;
  final HomeRepository _homeRepository;
  final ThemeController _themeController;

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
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget._themeController.addListener(_handleThemeChanged);
  }

  @override
  void dispose() {
    widget._themeController
      ..removeListener(_handleThemeChanged)
      ..dispose();
    super.dispose();
  }

  void _handleThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Application',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: widget._themeController.themeMode,
      home: AuthGate(
        repository: widget._authRepository,
        themeMode: widget._themeController.themeMode,
        onThemeModeChanged: widget._themeController.setThemeMode,
        signedInBuilder: (_, user) => _AuthenticatedHomeScreen(
          key: ValueKey(user.id),
          repository: widget._homeRepository,
          onSignOut: widget._authRepository.signOut,
          themeMode: widget._themeController.themeMode,
          onThemeModeChanged: widget._themeController.setThemeMode,
        ),
      ),
    );
  }
}

class _AuthenticatedHomeScreen extends StatefulWidget {
  const _AuthenticatedHomeScreen({
    required this.repository,
    required this.onSignOut,
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final HomeRepository repository;
  final Future<void> Function() onSignOut;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

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
    return HomeScreen(
      controller: _controller,
      onSignOut: widget.onSignOut,
      themeMode: widget.themeMode,
      onThemeModeChanged: widget.onThemeModeChanged,
    );
  }
}
