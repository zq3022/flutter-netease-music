import 'package:dio/dio.dart';

import 'dio_response.dart';

class DioInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 更多业务需求
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 请求成功是对数据做基本处理
    if (response.statusCode == 200) {
      response.data =
          DioResponse(code: 0, message: '请求成功啦', data: response.data);
    } else {
      response.data =
          DioResponse(code: 1, message: '请求失败啦', data: response.data);
    }

    // 对某些单独的url返回数据做特殊处理
    // if (response.requestOptions.baseUrl.contains('???????')) {
      //....
    // }

    // 根据公司的业务需求进行定制化处理

    // 重点
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      // 证书错误
      case DioExceptionType.badCertificate:
        {
          // 根据自己的业务需求来设定该如何操作,可以是弹出框提示/或者做一些路由跳转处理
        }
        break;
      // 连接服务器失败
      case DioExceptionType.connectionError:
        {
          // 根据自己的业务需求来设定该如何操作,可以是弹出框提示/或者做一些路由跳转处理
        }
        break;
      // 连接服务器超时
      case DioExceptionType.connectionTimeout:
        {
          // 根据自己的业务需求来设定该如何操作,可以是弹出框提示/或者做一些路由跳转处理
        }
        break;
      // 响应超时
      case DioExceptionType.receiveTimeout:
        {
          // 根据自己的业务需求来设定该如何操作,可以是弹出框提示/或者做一些路由跳转处理
        }
        break;
      // 发送超时
      case DioExceptionType.sendTimeout:
        {
          // 根据自己的业务需求来设定该如何操作,可以是弹出框提示/或者做一些路由跳转处理
        }
        break;
      // 请求取消
      case DioExceptionType.cancel:
        {
          // 根据自己的业务需求来设定该如何操作,可以是弹出框提示/或者做一些路由跳转处理
        }
        break;
      // 404/503错误
      case DioExceptionType.badResponse:
        {
          // 根据自己的业务需求来设定该如何操作,可以是弹出框提示/或者做一些路由跳转处理
        }
        break;
      // other 其他错误类型
      case DioExceptionType.unknown:
        {}
        break;
    }
    super.onError(err, handler);
  }
}
