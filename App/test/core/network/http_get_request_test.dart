import 'package:fitness_application/core/network/http_get_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('resolves a path and forwards headers', () async {
    final request = createHttpGetRequest(
      baseUrl: Uri.parse('http://localhost:8000'),
      client: MockClient((request) async {
        expect(request.url, Uri.parse('http://localhost:8000/v1/home'));
        expect(request.headers['Authorization'], 'Bearer firebase-token');

        return http.Response('{"data": {}, "meta": {}, "error": null}', 200);
      }),
    );

    final response = await request(
      '/v1/home',
      headers: {'Authorization': 'Bearer firebase-token'},
    );

    expect(response.statusCode, 200);
    expect(response.body['data'], isA<Map<String, dynamic>>());
  });

  test('returns a failure envelope when JSON is invalid', () async {
    final request = createHttpGetRequest(
      baseUrl: Uri.parse('http://localhost:8000'),
      client: MockClient((request) async => http.Response('[]', 200)),
    );

    final response = await request('/v1/home', headers: const {});

    expect(response.statusCode, 500);
    expect(response.body, {
      'data': null,
      'meta': null,
      'error': {
        'code': 'NETWORK_REQUEST_FAILED',
        'message': 'Network request failed.',
      },
    });
  });
}
