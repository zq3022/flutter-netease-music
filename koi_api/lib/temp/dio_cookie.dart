import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../dio_config/dio_config.dart';

class DioCookie {

  factory DioCookie() => _instance ?? DioCookie._internal();

  DioCookie._internal() {
    _instance = this;
    _instance!._init();
  }

  static DioCookie? _instance;

  static DioCookie? getInstance() {
    _instance ?? DioCookie._internal();
    return _instance;
  }

  _init() {
    scheduleMicrotask(() async {
      PersistCookieJar? cookieJar;
      var documentDir = (await getApplicationDocumentsDirectory()).path;
      if (Platform.isWindows || Platform.isLinux) {
        documentDir = p.join(documentDir, 'quiet');
      }
      final cookiePath = p.join(documentDir, 'cookie');
      // final cachePath = p.join(documentDir, 'cache');

      try {
        cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
      } catch (e) {
        debugPrint('error: can not create persist cookie jar');
      }
      _cookieJar.complete(cookieJar);
    });
  }

  final Completer<PersistCookieJar> _cookieJar = Completer();

  Future<List<Cookie>> loadCookies() async {
    final jar = await _cookieJar.future;
    final uri = Uri.parse(DioConfig.baseUrl);
    return jar.loadForRequest(uri);
  }

  Future<void> saveCookies(List<Cookie> cookies) async {
    final jar = await _cookieJar.future;
    await jar.saveFromResponse(Uri.parse(DioConfig.baseUrl), cookies);
  }
}