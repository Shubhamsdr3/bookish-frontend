import 'dart:async';

import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'
    show GlobalKey, NavigatorState, VoidCallback, WidgetsFlutterBinding;
import 'package:network_service/util/constants.dart';

import 'curl_logging_dio_interceptor.dart';
import 'interceptors/auth_interceptor.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  Dio? _apiClient;
  Alice? _alice;
  AliceDioAdapter? _aliceAdapter;
  bool _initialized = false;

  ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  bool get isInitialized => _initialized;

  /// Optional callback when a 401 is detected (e.g., navigate to login)
  VoidCallback? onSessionExpired;

  Dio get apiClient {
    _apiClient ??= _createApiClient();
    return _apiClient!;
  }

  bool get isAliceEnabled => kDebugMode;

  Alice get alice {
    if (!kDebugMode) {
      throw StateError('Alice is only available in debug mode.');
    }
    if (_alice == null) {
      if (!_initialized) {
        throw StateError(
          'ApiService has not been initialized. Call initialize() first.',
        );
      }
      _aliceAdapter ??= AliceDioAdapter();
      _alice = Alice(
        configuration: AliceConfiguration(
          showNotification: true,
          showInspectorOnShake: true,
        ),
      )..addAdapter(_aliceAdapter!);
    }
    return _alice!;
  }

  GlobalKey<NavigatorState>? get aliceNavigatorKey {
    if (!kDebugMode || !_initialized) {
      return null;
    }
    return alice.getNavigatorKey();
  }

  Dio _createApiClient() {
    WidgetsFlutterBinding.ensureInitialized();
    return Dio(
      BaseOptions(
        followRedirects: false,
        baseUrl: Constants.BASE_URL,
        contentType: Headers.jsonContentType,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<void> initialize({VoidCallback? onSessionExpired}) async {
    this.onSessionExpired = onSessionExpired;
    _apiClient ??= _createApiClient();
    // Honor environment set by the app (e.g. main.dart) before initialize().
    apiClient.options.baseUrl = Constants.BASE_URL;
    _initialized = true;

    final client = _apiClient!;
    if (!client.interceptors.any((interceptor) => interceptor is AuthInterceptor)) {
      client.interceptors.add(
        AuthInterceptor(onSessionExpired: onSessionExpired),
      );
    }

    if (kDebugMode) {
      _aliceAdapter ??= AliceDioAdapter();
      _alice ??= Alice(
        configuration: AliceConfiguration(
          showNotification: true,
          showInspectorOnShake: true,
        ),
      )..addAdapter(_aliceAdapter!);

      if (!client.interceptors.any((interceptor) => interceptor == _aliceAdapter)) {
        client.interceptors.add(_aliceAdapter!);
      }
      if (!client.interceptors.any(
          (interceptor) => interceptor is CurlLoggerDioInterceptor)) {
        client.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
      }
    }
  }

  void setHeaders(Map<String, String> headers) {
    apiClient.options.headers.addAll(headers);
  }

  void removeHeaders(List<String> headers) {
    for (final header in headers) {
      apiClient.options.headers.remove(header);
    }
  }
}
