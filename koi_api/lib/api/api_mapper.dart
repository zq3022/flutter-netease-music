import '../dio_util/dio_method.dart';

final openApis = <String, List<dynamic>>{
  'login': ['/member/auth/login', DioMethod.post],
  'logout': ['/member/auth/logout', DioMethod.post],
  'isLogin': ['/member/auth/is-login', DioMethod.post],
  'signUp': ['/member/auth/sign-up', DioMethod.post],
  'refreshToken': ['/member/auth/refresh-token', DioMethod.post],
  'mobileExist': ['/member/auth/mobile-exist', DioMethod.post],
};

final authApis = <String, List<dynamic>>{
  'userDetail': ['/cf/user/detail', DioMethod.get],
  'userPlaylist': ['/cf/playlist/list', DioMethod.get],
  'playlistDetail': ['/cf/playlist/detail', DioMethod.get],
};

class ApiMapper {
  static bool isOpen(String? pathKey) {
    return pathKey != null && openApis[pathKey] != null;
  }

  static List<dynamic>? getApi(String pathKey) {
    return isOpen(pathKey) ? openApis[pathKey] : authApis[pathKey];
  }
}
