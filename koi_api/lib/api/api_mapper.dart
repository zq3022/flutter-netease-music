final openApis = <String, String>{
  'login': '/member/auth/login',
};

final authApis = <String, String>{
  'key': 'value',
};

class ApiMapper {
  static bool isOpen(String pathKey) {
    return openApis[pathKey] == null;
  }

  static String? getApi(String pathKey) {
    return isOpen(pathKey) ? openApis[pathKey] : authApis[pathKey];
  }
}
