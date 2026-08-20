import 'package:fitness_application/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps an API error envelope to a typed failure', () async {
    final client = ApiClient(
      tokenProvider: () async => 'firebase-token',
      getRequest: (_, {required headers}) async {
        expect(headers['Authorization'], 'Bearer firebase-token');
        return const ApiResponse(
          statusCode: 401,
          body: {
            'data': null,
            'meta': null,
            'error': {
              'code': 'AUTHENTICATION_REQUIRED',
              'message': 'Sign in again.',
            },
          },
        );
      },
    );

    final result = await client.get('/v1/home', (json) => json);

    expect(result.failure?.code, 'AUTHENTICATION_REQUIRED');
  });
}
