typedef TokenProvider = Future<String?> Function();
typedef GetRequest =
    Future<ApiResponse> Function(
      String path, {
      required Map<String, String> headers,
    });

class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic> body;
}

class ApiFailure {
  const ApiFailure({required this.code, required this.message});

  final String code;
  final String message;
}

class ApiResult<T> {
  const ApiResult.success(this.data) : failure = null;
  const ApiResult.failure(this.failure) : data = null;

  final T? data;
  final ApiFailure? failure;
}

class ApiClient {
  const ApiClient({
    required this.tokenProvider,
    required this.getRequest,
  });

  final TokenProvider tokenProvider;
  final GetRequest getRequest;

  Future<ApiResult<T>> get<T>(
    String path,
    T Function(Map<String, dynamic>) decoder,
  ) async {
    final token = await tokenProvider();
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await getRequest(path, headers: headers);
    final error = response.body['error'];
    if (response.statusCode >= 400 && error is Map<String, dynamic>) {
      return ApiResult.failure(
        ApiFailure(
          code: error['code'] as String? ?? 'UNKNOWN_ERROR',
          message: error['message'] as String? ?? 'Request failed.',
        ),
      );
    }
    final data = response.body['data'];
    if (data is Map<String, dynamic>) return ApiResult.success(decoder(data));
    return const ApiResult.failure(
      ApiFailure(code: 'INVALID_RESPONSE', message: 'Invalid API response.'),
    );
  }
}
