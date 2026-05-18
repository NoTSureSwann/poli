import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfigService {
  static String _trimTrailingSlash(String value) =>
      value.replaceFirst(RegExp(r'/+$'), '');

  static String get apiBaseUrl {
    final envBase = dotenv.env['API_BASE_URL']?.trim();
    if (envBase != null && envBase.isNotEmpty) {
      return _trimTrailingSlash(envBase);
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static String get serverBaseUrl {
    final base = apiBaseUrl;
    if (base.endsWith('/api')) {
      return base.substring(0, base.length - 4);
    }
    return base;
  }

  static Uri apiUri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final query = queryParameters?.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return Uri.parse(
      '$apiBaseUrl$normalizedPath',
    ).replace(queryParameters: query);
  }

  static Uri serverUri(String path, {Map<String, dynamic>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final query = queryParameters?.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return Uri.parse(
      '$serverBaseUrl$normalizedPath',
    ).replace(queryParameters: query);
  }
}
