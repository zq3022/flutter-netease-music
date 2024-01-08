// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../dio_config/dio_config.dart';
import 'dio_method.dart';
import 'dio_token_interceptors.dart';

class DioUtil {
  factory DioUtil() => _instance ?? DioUtil._internal();

  DioUtil._internal() {
    _instance = this;
    _instance!._init();
  }

  static DioUtil? _instance;
  static Dio _dio = Dio();
  Dio get dio => _dio;

  static DioUtil? getInstance() {
    _instance ?? DioUtil._internal();
    return _instance;
  }

  /// 取消请求token
  final CancelToken _cancelToken = CancelToken();

  /// cookie
  // CookieJar cookieJar = CookieJar();

  _init() {
    /// 初始化基本选项
    BaseOptions options = BaseOptions(
      baseUrl: DioConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: DioConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: DioConfig.receiveTimeout),
    );

    /// 初始化dio
    _dio = Dio(options);

    /// 添加拦截器
    // _dio.interceptors.add(DioInterceptors());

    /// 添加转换器
    // _dio.transformer = DioTransformer();

    /// 添加cookie管理器
    // _dio.interceptors.add(CookieManager(cookieJar));

    /// 刷新token拦截器(lock/unlock)
    _dio.interceptors.add(DioTokenInterceptors());

    /// 添加缓存拦截器
    // _dio.interceptors.add(DioCacheInterceptors());
  }

  /// 设置Http代理(设置即开启)
  void setProxy({String? proxyAddress, bool enable = false}) {
    if (enable) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.findProxy = (uri) {
          return proxyAddress ?? '';
        };
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  /// 设置https证书校验
  void setHttpsCertificateVerification({String? pem, bool enable = false}) {
    if (enable) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          if (cert.pem == pem) {
            // 验证证书
            return true;
          }
          return false;
        };
      };
    }
  }

  /// 开启日志打印
  void openLog() {
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  /// 请求类
  Future<T> request<T>(
    String path, {
    DioMethod method = DioMethod.get,
    Map<String, dynamic>? params,
    Object? data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    const _methodValues = {
      DioMethod.get: 'get',
      DioMethod.post: 'post',
      DioMethod.put: 'put',
      DioMethod.delete: 'delete',
      DioMethod.patch: 'patch',
      DioMethod.head: 'head',
    };

    options ??= Options(method: _methodValues[method]);
    try {
      Response response;
      response = await _dio.request(path,
          data: data,
          queryParameters: params,
          cancelToken: cancelToken ?? _cancelToken,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  /// 取消网络请求
  void cancelRequests({CancelToken? token}) {
    token ?? _cancelToken.cancel('cancelled');
  }
}
