class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;
}

abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  Future<void> signInWithGoogle();

  Future<void> signOut();
}
