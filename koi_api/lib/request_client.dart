import 'package:dio/dio.dart';

import 'request_config.dart';

RequestClient requestClient = RequestClient();

class RequestClient {
  RequestClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: RequestConfig.baseUrl,
        connectTimeout:
            const Duration(milliseconds: RequestConfig.connectTimeout),
      ),
    );
  }
  late Dio _dio;

  Future<dynamic> request(String url,
      {String method = 'GET',
      Map<String, dynamic>? queryParameters,
      data,
      Map<String, dynamic>? headers}) async {
    Options options = Options()
      ..method = method
      ..headers = headers;

    Response response = await _dio.request(url,
        queryParameters: queryParameters, data: data, options: options);

    return response.data;
  }
}
