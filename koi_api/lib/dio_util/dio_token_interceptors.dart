import 'dart:convert';
import 'dart:ffi';

import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';

import '../api/api_mapper.dart';
import '../dio_config/dio_config.dart';
import 'dio_preferences_provider.dart';

/// 自动刷新token
/// 要求权限的请求，需要token。如果没有token，需要用refreshToken去刷新token,如果refreshToken都没有，先登录。
class DioTokenInterceptors extends QueuedInterceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 头部添加租户id
    options.headers[DioConfig.tanantHeader] = DioConfig.tanantValue;
    final _preference = PreferencesProvider();
    if (ApiMapper.isOpen(options.headers['_pathkey'])) {
      if (options.headers['_pathkey'] == 'login') {
        await _preference.clearAccess();
        await _preference.clearRefresh();
      }
      return handler.next(options);
    }
    LogUtil.e('${options.headers['_pathkey']} is notOpen');

    // token
    final tokenStr = (await _preference.getAccess())?.split('|');
    final refreshTokenStr = (await _preference.getRefresh())?.split('|');
    LogUtil.e(
        'refresh token dio request..............$tokenStr   $refreshTokenStr');
    LogUtil.e('refresh token dio request...............0');

    if (tokenStr != null &&
        DateTime.now().isBefore(
          DateTime.fromMillisecondsSinceEpoch(int.parse(tokenStr[1])),
        )) {
      LogUtil.e('refresh token dio request...............1');
      // token在有效期内
      options.headers[DioConfig.tokenHeader] = 'Bearer ${tokenStr[0]}';
    } else if (refreshTokenStr != null &&
        DateTime.now().isBefore(
          DateTime.fromMillisecondsSinceEpoch(int.parse(refreshTokenStr[1])),
        )) {
      LogUtil.e('refresh token dio request...............2');
      // token已过期，但存在refreshToken未过期
      await _preference.clearAccess();
      // refresh token
      LogUtil.e('refresh token dio request...............3');
      final result = await Dio(
        BaseOptions(
          baseUrl: DioConfig.baseUrl,
          connectTimeout:
              const Duration(milliseconds: DioConfig.connectTimeout),
          receiveTimeout:
              const Duration(milliseconds: DioConfig.receiveTimeout),
        ),
      ).post(
        ApiMapper.getApi('refreshToken')![0],
        data: {'refreshToken': refreshTokenStr[0]},
      );
      LogUtil.e('refresh token dio request...............4');
      LogUtil.e(result);
      if (result.statusCode != null && result.statusCode! ~/ 100 == 2) {
        LogUtil.e('refresh token dio request...............5');

        /// assume `token` is in response body
        final body = jsonDecode(result.data) as Map<String, dynamic>?;
        if (body != null && body.containsKey('data')) {
          await _preference
              .setAccess(body['accessToken'] + '|' + body['expiresTime']);
          await _preference
              .setRefresh(body['refreshToken'] + '|' + body['expiresTime']);
          options.headers[DioConfig.tokenHeader] = body['accessToken'];
          return handler.next(options);
        }
      }
    }
    LogUtil.e('refresh token dio request...............6');
    return handler.next(options);
    // return handler.reject(
    //   DioException(requestOptions: options),
    //   true,
    // );
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    LogUtil.e('dio_token_interceptors.onResponse::1');
    if (response.requestOptions.headers['_pathkey'] == 'login' ||
        response.requestOptions.headers['_pathkey'] == 'refreshToken') {
      LogUtil.e('dio_token_interceptors.onResponse::2');
      if (response.data['code'] == 0) {
        LogUtil.e('dio_token_interceptors.onResponse::3');
        // 设置token
        final body = response.data['data'];
        final _preference = PreferencesProvider();
        await _preference
            .setAccess('${body["accessToken"]}|${body["expiresTime"]}');
        await _preference
            .setRefresh('${body["refreshToken"]}|${body["expiresTime"]}');
        // final tokenStr = (await _preference.getAccess())?.split('|');
        // final refreshTokenStr = (await _preference.getRefresh())?.split('|');
      }
    }

    // 响应前需要做刷新token的操作
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }
}
