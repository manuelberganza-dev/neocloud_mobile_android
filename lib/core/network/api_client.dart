import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../security/token_storage.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'api_response.dart';

part 'api_client.g.dart';

class ApiClient {
  ApiClient({required Dio dio, required TokenStorage tokenStorage})
    : _dio = dio,
      _tokenStorage = tokenStorage {
    _dio.interceptors.add(_authInterceptor());
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Future<T> getData<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );

      return _readApiResponse(response, fromJson);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T?> getOptionalData<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );

      return _readOptionalApiResponse(response, fromJson);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> postData<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return _readApiResponse(response, fromJson);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> putData<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.put<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return _readApiResponse(response, fromJson);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> patchData<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.patch<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return _readApiResponse(response, fromJson);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> deleteData<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) fromJson,
  }) async {
    try {
      final response = await _dio.delete<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return _readApiResponse(response, fromJson);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<void> postVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      _readVoidApiResponse(response);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<void> patchVoid(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      _readVoidApiResponse(response);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<List<int>> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.bytes),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw ApiException(
          message: 'No se pudo descargar el archivo.',
          statusCode: response.statusCode,
        );
      }

      return response.data ?? const [];
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  T _readApiResponse<T>(
    Response<Object?> response,
    T Function(Object? json) fromJson,
  ) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Respuesta inesperada del servidor.',
        statusCode: response.statusCode,
      );
    }

    final envelope = ApiResponse<T>.fromJson(body, fromJson);
    if (!envelope.success) {
      throw ApiException(
        message: envelope.message ?? 'Error de API.',
        statusCode: response.statusCode,
        errors: envelope.errors,
        traceId: envelope.traceId,
      );
    }

    final data = envelope.data;
    if (data == null) {
      throw ApiException(
        message: 'La respuesta no contiene datos.',
        statusCode: response.statusCode,
        traceId: envelope.traceId,
      );
    }

    return data;
  }

  T? _readOptionalApiResponse<T>(
    Response<Object?> response,
    T Function(Object? json) fromJson,
  ) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Respuesta inesperada del servidor.',
        statusCode: response.statusCode,
      );
    }

    final envelope = ApiResponse<T>.fromJson(body, fromJson);
    if (!envelope.success) {
      throw ApiException(
        message: envelope.message ?? 'Error de API.',
        statusCode: response.statusCode,
        errors: envelope.errors,
        traceId: envelope.traceId,
      );
    }

    return envelope.data;
  }

  void _readVoidApiResponse(Response<Object?> response) {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Respuesta inesperada del servidor.',
        statusCode: response.statusCode,
      );
    }

    final envelope = ApiResponse<Object?>.fromJson(body, (json) => json);
    if (!envelope.success) {
      throw ApiException(
        message: envelope.message ?? 'Error de API.',
        statusCode: response.statusCode,
        errors: envelope.errors,
        traceId: envelope.traceId,
      );
    }
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
      onError: (error, handler) async {
        final shouldRefresh =
            error.response?.statusCode == 401 &&
            error.requestOptions.extra['authRetry'] != true &&
            error.requestOptions.path != ApiEndpoints.authRefresh &&
            error.requestOptions.path != ApiEndpoints.authLogin;

        if (!shouldRefresh) {
          handler.next(error);
          return;
        }

        final refreshed = await _refreshTokens();
        if (!refreshed) {
          await _tokenStorage.clear();
          handler.next(error);
          return;
        }

        try {
          final accessToken = await _tokenStorage.readAccessToken();
          final retryOptions = error.requestOptions.copyWith(
            headers: {
              ...error.requestOptions.headers,
              if (accessToken != null) 'Authorization': 'Bearer $accessToken',
            },
            extra: {...error.requestOptions.extra, 'authRetry': true},
          );
          final retryResponse = await _dio.fetch<Object?>(retryOptions);
          handler.resolve(retryResponse);
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    );
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiEnvironment.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    try {
      final response = await refreshDio.post<Object?>(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode != 200 ||
          response.data is! Map<String, dynamic>) {
        return false;
      }

      final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data! as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );

      final data = envelope.data;
      if (!envelope.success || data == null) {
        return false;
      }

      await _tokenStorage.save(
        StoredTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          accessTokenExpiresAt: DateTime.tryParse(
            data['accessTokenExpiresAt']?.toString() ?? '',
          ),
          refreshTokenExpiresAt: DateTime.tryParse(
            data['refreshTokenExpiresAt']?.toString() ?? '',
          ),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  ApiException _toApiException(DioException error) {
    final response = error.response;
    final body = response?.data;

    if (body is Map<String, dynamic>) {
      final envelope = ApiResponse<Object?>.fromJson(body, (json) => json);
      return ApiException(
        message: envelope.message ?? error.message ?? 'Error de red.',
        statusCode: response?.statusCode,
        errors: envelope.errors,
        traceId: envelope.traceId,
      );
    }

    return ApiException(
      message: error.message ?? 'Error de red.',
      statusCode: response?.statusCode,
    );
  }
}

@riverpod
Dio dio(Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiEnvironment.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    ),
  );
}

@riverpod
ApiClient apiClient(Ref ref) {
  return ApiClient(
    dio: ref.watch(dioProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
}
