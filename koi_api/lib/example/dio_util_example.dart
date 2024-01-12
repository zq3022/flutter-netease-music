import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../dio_util/dio_method.dart';
import '../dio_util/dio_response.dart';
import '../dio_util/dio_util.dart';

class DioUtilExample extends StatefulWidget {
  @override
  _DioUtilExampleState createState() => _DioUtilExampleState();
}

class _DioUtilExampleState extends State<DioUtilExample> {
  CancelToken _cancelToken = CancelToken();

  void _handleLogin() async {
    // 模拟用户退出页面
    // const _timeout = Duration(milliseconds: 2000);
    // Timer.periodic(_timeout, (timer) {
    //     DioUtil().cancelRequests(token: _cancelToken);
    // });

    // DioUtil().openLog();
    DioUtil.getInstance()?.openLog();
    // DioUtil.CACHE_ENABLE = true;
    // DioUtil().setProxy(proxyAddress: "https://www.baidu.com", enable: true);
    DioResponse result = await DioUtil().request('/login',
        params: {'username': '123456', 'password': '123456'},
        cancelToken: _cancelToken);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DioUtilExample'),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: _handleLogin,
              child: const Text('发送请求'),
            ),
          ],
        ),
      ),
    );
  }
}
