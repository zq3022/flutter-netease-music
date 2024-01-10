class DioConfig {
  // static const baseUrl =
  //     'http://www.fastmock.site/mock/6d5084df89b4c7a49b28052a0f51c29a/test';
  // static const connectTimeout = 15000;
  static const successCode = 200;

  /// 连接超时时间
  static const int connectTimeout = 15 * 1000;

  /// 响应超时时间
  static const int receiveTimeout = 30 * 1000;

  /// 域名
  static String domain = 'koiup.com';

  /// 请求的URL前缀
  static String baseUrl = 'http://localhost:48080/app-api';

  /// 刷新token的请求URL
  static String refreshTokenUrl = '/member/auth/refresh-token';

  /// 是否开启网络缓存,默认false
  static bool cacheEnable = false;

  /// 最大缓存时间(按秒), 默认缓存七天,可自行调节
  static int maxCacheAge = 7 * 24 * 60 * 60;

  /// 最大缓存条数(默认一百条)
  static int maxCacheCount = 100;

  /// 请求头部的token属性名称
  static String tokenHeader = 'Authorization';

  /// 请求头部的tanant_id属性名称
  static String tanantHeader = 'tenant-id';

  /// 请求头部的tanant_id属性的值
  static int tanantValue = 1;
}
