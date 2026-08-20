import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/core/network/http_get_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('maps token provider exceptions to a stable network failure', () async {
    final client = ApiClient(
      tokenProvider: () async => throw Exception('token lookup failed'),
      getRequest: (_, {required headers}) async {
        return const ApiResponse(
          statusCode: 200,
          body: {
            'data': {'request': 'completed'},
            'meta': {},
            'error': null,
          },
        );
      },
    );

    final result = await client.get('/v1/home', (json) => json);

    expect(result.data, isNull);
    expect(result.failure?.code, 'NETWORK_REQUEST_FAILED');
    expect(result.failure?.message, 'Network request failed.');
  });

  test('maps request exceptions to a stable network failure', () async {
    final client = ApiClient(
      tokenProvider: () async => 'firebase-token',
      getRequest: (_, {required headers}) async =>
          throw Exception('socket failed'),
    );

    final result = await client.get('/v1/home', (json) => json);

    expect(result.data, isNull);
    expect(result.failure?.code, 'NETWORK_REQUEST_FAILED');
    expect(result.failure?.message, 'Network request failed.');
  });

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

  test('treats the HTTP error threshold as failure without an error', () async {
    final client = ApiClient(
      tokenProvider: () async => null,
      getRequest: (_, {required headers}) async {
        return const ApiResponse(
          statusCode: 400,
          body: {
            'data': {'looks': 'valid'},
            'meta': {},
            'error': null,
          },
        );
      },
    );

    final result = await client.get('/v1/home', (json) => json);

    expect(result.data, isNull);
    expect(result.failure?.code, 'UNKNOWN_ERROR');
    expect(result.failure?.message, 'Request failed.');
  });

  test('uses safe fallbacks for a malformed HTTP error', () async {
    final client = ApiClient(
      tokenProvider: () async => null,
      getRequest: (_, {required headers}) async {
        return const ApiResponse(
          statusCode: 503,
          body: {
            'data': {'looks': 'valid'},
            'meta': {},
            'error': {
              'code': 503,
              'message': ['temporarily unavailable'],
            },
          },
        );
      },
    );

    final result = await client.get('/v1/home', (json) => json);

    expect(result.data, isNull);
    expect(result.failure?.code, 'UNKNOWN_ERROR');
    expect(result.failure?.message, 'Request failed.');
  });

  test(
    'maps a non-object 200 response from the adapter to NETWORK_REQUEST_FAILED',
    () async {
      final client = ApiClient(
        tokenProvider: () async => 'firebase-token',
        getRequest: createHttpGetRequest(
          baseUrl: Uri.parse('http://localhost:8000'),
          client: MockClient((request) async {
            expect(request.url, Uri.parse('http://localhost:8000/v1/home'));
            expect(request.headers['Authorization'], 'Bearer firebase-token');
            return http.Response('[]', 200);
          }),
        ),
      );

      final result = await client.get('/v1/home', (json) => json);

      expect(result.data, isNull);
      expect(result.failure?.code, 'NETWORK_REQUEST_FAILED');
    },
  );
}
