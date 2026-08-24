import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';

PostRequest createHttpPostRequest({
  required Uri baseUrl,
  http.Client? client,
  Duration timeout = const Duration(seconds: 15),
}) {
  final effectiveClient = client ?? http.Client();

  return (path, {required headers, required body}) async {
    try {
      final response = await effectiveClient
          .post(baseUrl.resolve(path), headers: headers, body: jsonEncode(body))
          .timeout(timeout);
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is Map<String, dynamic>) {
        return ApiResponse(statusCode: response.statusCode, body: decodedBody);
      }
    } on Exception {
      // Convert transport and decoding errors into the stable API failure envelope.
    }
    return ApiResponse(
      statusCode: 500,
      body: {
        'data': null,
        'meta': null,
        'error': {
          'code': 'NETWORK_REQUEST_FAILED',
          'message': 'Network request failed.',
        },
      },
    );
  };
}
