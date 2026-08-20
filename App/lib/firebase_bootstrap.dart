import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

typedef FirebaseInitializer = Future<void> Function();

Future<void> bootstrapFirebase([FirebaseInitializer? initialize]) {
  return (initialize ?? _initializeFirebase)();
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
