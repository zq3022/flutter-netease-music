class DioConfig {
  // static const baseUrl =
  //     'http://www.fastmock.site/mock/6d5084df89b4c7a49b28052a0f51c29a/test';
  // static const connectTimeout = 15000;
  static const successCode = 200;

  /// 连接超时时间
  static const int connectTimeout = 15 * 1000;

  /// 响应超时时间
  static const int receiveTimeout = 6 * 1000;

  /// 请求的URL前缀
  static String baseUrl = 'http://localhost:8080';

  /// 刷新token的请求URL
  static String refreshTokenUrl = 'http://localhost:8080';

  /// 是否开启网络缓存,默认false
  static bool cacheEnable = false;

  /// 最大缓存时间(按秒), 默认缓存七天,可自行调节
  static int maxCacheAge = 7 * 24 * 60 * 60;

  /// 最大缓存条数(默认一百条)
  static int maxCacheCount = 100;

  /// 请求头部的token属性名称
  static String tokenHeader = 'Authorization';
}
