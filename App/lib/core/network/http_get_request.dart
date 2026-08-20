import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';

GetRequest createHttpGetRequest({required Uri baseUrl, http.Client? client}) {
  final effectiveClient = client ?? http.Client();

  return (path, {required headers}) async {
    try {
      final response = await effectiveClient.get(
        baseUrl.resolve(path),
        headers: headers,
      );
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is Map<String, dynamic>) {
        return ApiResponse(statusCode: response.statusCode, body: decodedBody);
      }

      return _networkFailure(
        response.statusCode >= 400 ? response.statusCode : 500,
      );
    } on FormatException {
      return _networkFailure();
    } on Exception {
      return _networkFailure();
    }
  };
}

ApiResponse _networkFailure([int statusCode = 500]) {
  return ApiResponse(
    statusCode: statusCode,
    body: {
      'data': null,
      'meta': null,
      'error': {
        'code': 'NETWORK_REQUEST_FAILED',
        'message': 'Network request failed.',
      },
    },
  );
}
