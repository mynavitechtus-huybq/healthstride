typedef TokenProvider = Future<String?> Function();
typedef GetRequest =
    Future<ApiResponse> Function(
      String path, {
      required Map<String, String> headers,
    });
typedef PostRequest =
    Future<ApiResponse> Function(
      String path, {
      required Map<String, String> headers,
      required Map<String, dynamic> body,
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
    this.postRequest,
  });

  final TokenProvider tokenProvider;
  final GetRequest getRequest;
  final PostRequest? postRequest;

  Future<ApiResult<T>> get<T>(
    String path,
    T Function(Map<String, dynamic>) decoder,
  ) async {
    late final ApiResponse response;
    try {
      final token = await tokenProvider();
      final headers = <String, String>{
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      response = await getRequest(path, headers: headers);
    } catch (_) {
      return const ApiResult.failure(
        ApiFailure(
          code: 'NETWORK_REQUEST_FAILED',
          message: 'Network request failed.',
        ),
      );
    }

    final error = response.body['error'];
    if (response.statusCode >= 400) {
      final errorCode = error is Map<String, dynamic> ? error['code'] : null;
      final errorMessage = error is Map<String, dynamic>
          ? error['message']
          : null;
      return ApiResult.failure(
        ApiFailure(
          code: errorCode is String ? errorCode : 'UNKNOWN_ERROR',
          message: errorMessage is String ? errorMessage : 'Request failed.',
        ),
      );
    }
    final data = response.body['data'];
    if (data is Map<String, dynamic>) return ApiResult.success(decoder(data));
    return const ApiResult.failure(
      ApiFailure(code: 'INVALID_RESPONSE', message: 'Invalid API response.'),
    );
  }

  Future<ApiResult<T>> post<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) decoder, {
    required Map<String, String> extraHeaders,
  }) async {
    final request = postRequest;
    if (request == null) {
      return const ApiResult.failure(
        ApiFailure(
          code: 'NETWORK_REQUEST_FAILED',
          message: 'Network request failed.',
        ),
      );
    }

    late final ApiResponse response;
    try {
      final token = await tokenProvider();
      response = await request(
        path,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          ...extraHeaders,
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      );
    } catch (_) {
      return const ApiResult.failure(
        ApiFailure(
          code: 'NETWORK_REQUEST_FAILED',
          message: 'Network request failed.',
        ),
      );
    }

    try {
      return _decodeResponse(response, decoder);
    } on FormatException {
      return const ApiResult.failure(
        ApiFailure(code: 'INVALID_RESPONSE', message: 'Invalid API response.'),
      );
    } on TypeError {
      return const ApiResult.failure(
        ApiFailure(code: 'INVALID_RESPONSE', message: 'Invalid API response.'),
      );
    }
  }

  ApiResult<T> _decodeResponse<T>(
    ApiResponse response,
    T Function(Map<String, dynamic>) decoder,
  ) {
    final error = response.body['error'];
    if (response.statusCode >= 400) {
      final errorCode = error is Map<String, dynamic> ? error['code'] : null;
      final errorMessage = error is Map<String, dynamic>
          ? error['message']
          : null;
      return ApiResult.failure(
        ApiFailure(
          code: errorCode is String ? errorCode : 'UNKNOWN_ERROR',
          message: errorMessage is String ? errorMessage : 'Request failed.',
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
