import 'package:fitness_application/core/config/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rejects an absent API base URL', () {
    expect(() => AppEnvironment.fromApiBaseUrl(''), throwsArgumentError);
  });

  test('accepts an absolute API base URL', () {
    final value = AppEnvironment.fromApiBaseUrl('http://127.0.0.1:8000');

    expect(value.apiBaseUrl.toString(), 'http://127.0.0.1:8000');
  });
}
