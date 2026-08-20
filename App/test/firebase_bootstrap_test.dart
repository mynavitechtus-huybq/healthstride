import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_application/firebase_bootstrap.dart';

void main() {
  test('bootstrap initializes Firebase before the app starts', () async {
    var initialized = false;

    await bootstrapFirebase(() async {
      initialized = true;
    });

    expect(initialized, isTrue);
  });
}
