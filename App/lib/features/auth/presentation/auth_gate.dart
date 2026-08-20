import 'package:flutter/material.dart';

import '../domain/auth_repository.dart';

typedef SignedInBuilder = Widget Function(BuildContext context, AuthUser user);

class AuthGate extends StatefulWidget {
  const AuthGate({
    required this.repository,
    required this.signedInBuilder,
    super.key,
  });

  final AuthRepository repository;
  final SignedInBuilder signedInBuilder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isSigningIn = false;
  bool _hasSignInError = false;

  Future<void> _signIn() async {
    setState(() {
      _isSigningIn = true;
      _hasSignInError = false;
    });

    try {
      await widget.repository.signInWithGoogle();
    } catch (_) {
      if (mounted) {
        setState(() => _hasSignInError = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: widget.repository.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return widget.signedInBuilder(context, user);
        }

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'HealthStride',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Build healthy habits with your community.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: _isSigningIn ? null : _signIn,
                        icon: _isSigningIn
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login),
                        label: const Text('Continue with Google'),
                      ),
                      if (_hasSignInError) ...[
                        const SizedBox(height: 16),
                        Text(
                          'We could not sign you in. Try again.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
