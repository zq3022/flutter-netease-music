import '../dio_util/dio_method.dart';

final openApis = <String, List<dynamic>>{
  'login': ['/member/auth/login', DioMethod.post],
  'refreshToken': ['/member/auth/refresh-token', DioMethod.post],
  'mobileExist': ['/member/auth/mobile-exist', DioMethod.post],
};

final authApis = <String, List<dynamic>>{
  'userDetail': ['/member/user/get', DioMethod.get],
};

class ApiMapper {
  static bool isOpen(String? pathKey) {
    return pathKey != null && openApis[pathKey] != null;
  }

  static List<dynamic>? getApi(String pathKey) {
    return isOpen(pathKey) ? openApis[pathKey] : authApis[pathKey];
  }
}
