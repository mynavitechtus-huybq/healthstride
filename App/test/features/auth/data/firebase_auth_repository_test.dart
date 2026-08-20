// ignore_for_file: depend_on_referenced_packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:fitness_application/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  group('FirebaseAuthRepository.getIdToken', () {
    late FirebaseAuth auth;
    late _TestFirebaseAuthPlatform authPlatform;
    var appCount = 0;

    setUp(() async {
      authPlatform = _TestFirebaseAuthPlatform();
      FirebaseAuthPlatform.instance = authPlatform;

      final app = await Firebase.initializeApp(
        name: 'auth-repository-$appCount',
        options: const FirebaseOptions(
          apiKey: 'api-key',
          appId: 'app-id',
          messagingSenderId: 'sender-id',
          projectId: 'project-id',
        ),
      );
      auth = FirebaseAuth.instanceFor(app: app);
      appCount++;
    });

    test('returns null when there is no current user', () async {
      final repository = FirebaseAuthRepository(firebaseAuth: auth);

      expect(await repository.getIdToken(), isNull);
    });

    test('forwards forceRefresh to Firebase current user', () async {
      authPlatform.currentUser = _TestUserPlatform(
        authPlatform,
        token: 'firebase-token',
      );
      final repository = FirebaseAuthRepository(firebaseAuth: auth);

      final token = await repository.getIdToken(forceRefresh: true);

      expect(token, 'firebase-token');
      expect(authPlatform.lastForceRefresh, isTrue);
    });
  });
}

class _TestFirebaseAuthPlatform extends FirebaseAuthPlatform {
  UserPlatform? _currentUser;

  bool? lastForceRefresh;

  @override
  UserPlatform? get currentUser => _currentUser;

  @override
  set currentUser(UserPlatform? userPlatform) {
    _currentUser = userPlatform;
  }

  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseAuthPlatform setInitialValues({
    InternalUserDetails? currentUser,
    String? languageCode,
  }) {
    return this;
  }
}

class _TestUserPlatform extends UserPlatform {
  _TestUserPlatform(FirebaseAuthPlatform auth, {required this.token})
    : super(
        auth,
        _TestMultiFactorPlatform(auth),
        InternalUserDetails(
          userInfo: InternalUserInfo(
            uid: 'user-1',
            email: 'ari@example.com',
            displayName: 'Ari',
            creationTimestamp: 0,
            lastSignInTimestamp: 0,
            isAnonymous: false,
            isEmailVerified: true,
          ),
          providerData: const <Map<String, dynamic>>[],
        ),
      );

  final String token;

  @override
  Future<String?> getIdToken(bool forceRefresh) async {
    (auth as _TestFirebaseAuthPlatform).lastForceRefresh = forceRefresh;
    return token;
  }
}

class _TestMultiFactorPlatform extends MultiFactorPlatform {
  _TestMultiFactorPlatform(super.auth);
}
