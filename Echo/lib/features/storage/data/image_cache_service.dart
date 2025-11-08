import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Map<String, Uint8List> _webImageCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  static const Duration _cacheExpiration = Duration(hours: 1);

  Future<Uint8List?> getImage(String url, Map<String, String>? headers) async {
    if (kIsWeb) {
      if (_webImageCache.containsKey(url)) {
        final timestamp = _cacheTimestamps[url];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < _cacheExpiration) {
          return _webImageCache[url];
        } else {
          _webImageCache.remove(url);
          _cacheTimestamps.remove(url);
        }
      }

      try {
        final response = await http.get(Uri.parse(url), headers: headers);

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          _webImageCache[url] = bytes;
          _cacheTimestamps[url] = DateTime.now();
          return bytes;
        }
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((url, timestamp) {
      if (now.difference(timestamp) >= _cacheExpiration) {
        expiredKeys.add(url);
      }
    });

    for (final key in expiredKeys) {
      _webImageCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  void clearAllCache() {
    _webImageCache.clear();
    _cacheTimestamps.clear();
  }

  void removeFromCache(String url) {
    _webImageCache.remove(url);
    _cacheTimestamps.remove(url);
  }
}
