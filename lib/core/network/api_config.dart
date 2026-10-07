import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const urlDefinida = String.fromEnvironment('API_URL');

    if (urlDefinida.isNotEmpty) {
      return urlDefinida;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://localhost:3000';
  }
}
