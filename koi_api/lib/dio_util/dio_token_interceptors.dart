import 'dart:js_interop_unsafe';

import 'package:dio/dio.dart';

import '../api/api_mapper.dart';
import '../dio_config/dio_config.dart';
import '../temp/dio_cookie.dart';
import 'dio_preferences_provider.dart';

/// 自动刷新token
/// 要求权限的请求，需要token。如果没有token，需要用refreshToken去刷新token,如果refreshToken都没有，先登录。
class DioTokenInterceptors extends QueuedInterceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (ApiMapper.isOpen(options.headers['_pathkey'])) {
      handler.next(options);
      return;
    }
    // 头部添加租户id
    options.headers[DioConfig.tanantHeader] = DioConfig.tanantValue;
    
    // token
    final _preference = PreferencesProvider();
    final tokenStr = await _preference.getAccess();
    final tokenTimestamp = _preference.getTokenTimestamp();
    

    final refreshToken = _preference.getAccess();
    final refreshTokenTimestamp = _preference.getRefreshTokenTimestamp();

    final refreshTimestamp = DateTime.parse(refreshTokenTimestamp);
    final currentTime = DateTime.now();
    final tokenDuration = currentTime.difference(DateTime.parse(tokenTimestamp));
    const Duration tokenExpirationDuration = Duration(hours: 1);
    if (tokenDuration <= tokenExpirationDuration) {
      return token;
    } else {
      await clearAccessToken();
      return null;
    }

    if (token == null && refreshToken != null) {
      // 刷新token
      options.headers[DioConfig.tokenHeader] = 
    } else if (refreshToken == null) {
      // 重新登录
    }


    if (data['success']) {
      await _preference.clearAccess();
      _preference.setUserId(data['userId'])
        ..setAccess(data['accessToken'])
        ..setRefresh(data['refreshToken']);
      _apiProvider.setToken(data["accessToken"]);
    }

    // refresh token
    String? refreshToken = cache.getProperty(CacheKey.refreshToken);
    if (refreshToken != null) {
      final result = await Dio().get(DioConfig.refreshTokenUrl);
      if (result.statusCode != null && result.statusCode! ~/ 100 == 2) {
        /// assume `token` is in response body
        final body = jsonDecode(result.data) as Map<String, dynamic>?;

        if (body != null && body.containsKey('data')) {
          options.headers['csrfToken'] = csrfToken = body['data']['token'];
          print('request token succeed, value: $csrfToken');
          print(
            'continue to perform request：path:${options.path}，baseURL:${options.path}',
          );
          return handler.next(options);
        }
      }
      Dio().get(DioConfig.refreshTokenUrl).then((d) {
        options.headers[DioConfig.tanantHeader] = DioConfig.tanantValue;
        options.headers[DioConfig.tokenHeader] = d;
        handler.next(options);
      }).catchError((error, stackTrace) {
        handler.reject(error, true);
      });

      return handler.reject(
        DioException(requestOptions: result.requestOptions),
        true,
      );
    } else {
      // options.headers['refreshToken'] = options.headers['refreshToken'];
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 响应前需要做刷新token的操作

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('send request：path:${options.path}，baseURL:${options.baseUrl}');

    if (csrfToken == null) {
      print('no token，request token firstly...');

      final result = await tokenDio.get('/token');

      if (result.statusCode != null && result.statusCode! ~/ 100 == 2) {
        /// assume `token` is in response body
        final body = jsonDecode(result.data) as Map<String, dynamic>?;

        if (body != null && body.containsKey('data')) {
          options.headers['csrfToken'] = csrfToken = body['data']['token'];
          print('request token succeed, value: $csrfToken');
          print(
            'continue to perform request：path:${options.path}，baseURL:${options.path}',
          );
          return handler.next(options);
        }
      }

      return handler.reject(
        DioException(requestOptions: result.requestOptions),
        true,
      );
    }

    options.headers['csrfToken'] = csrfToken;
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    /// Assume 401 stands for token expired
    if (err.response?.statusCode == 401) {
      print('the token has expired, need to receive new token');
      final options = err.response!.requestOptions;

      /// assume receiving the token has no errors
      /// to check `null-safety` and error handling
      /// please check inside the [onRequest] closure
      final tokenResult = await tokenDio.get('/token');

      /// update [csrfToken]
      /// assume `token` is in response body
      final body = jsonDecode(tokenResult.data) as Map<String, dynamic>?;
      options.headers['csrfToken'] = csrfToken = body!['data']['token'];

      if (options.headers['csrfToken'] != null) {
        print('the token has been updated');

        /// since the api has no state, force to pass the 401 error
        /// by adding query parameter
        final originResult = await dio.fetch(options..path += '&pass=true');
        if (originResult.statusCode != null &&
            originResult.statusCode! ~/ 100 == 2) {
          return handler.resolve(originResult);
        }
      }
      print('the token has not been updated');
      return handler.reject(
        DioException(requestOptions: options),
      );
    }
    return handler.next(err);
  }
}
