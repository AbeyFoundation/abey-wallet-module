import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ImageCacheManager extends CacheManager {
  static const key = 'libEsoCachedImageData';

  static ImageCacheManager? _instance;
  factory ImageCacheManager() {
    _instance ??= ImageCacheManager._();
    return _instance!;
  }

  ImageCacheManager._() : super(Config(key, fileService: EsoHttpFileService()));
}

class EsoHttpFileService extends FileService {
  HttpClient? _httpClient;
  EsoHttpFileService({HttpClient? httpClient}) {
    _httpClient = httpClient ?? HttpClient();
    _httpClient!.badCertificateCallback = (cert, host, port) => true;
  }

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers = const {}}) async {
    final Uri resolved = Uri.base.resolve(url);
    final HttpClientRequest req = await _httpClient!.getUrl(resolved);
    headers?.forEach((key, value) {
      req.headers.add(key, value);
    });
    final HttpClientResponse httpResponse = await req.close();
    final http.StreamedResponse _response = http.StreamedResponse(
      httpResponse.timeout(Duration(seconds: 60)), httpResponse.statusCode,
      contentLength: httpResponse.contentLength,
      reasonPhrase: httpResponse.reasonPhrase,
      isRedirect: httpResponse.isRedirect,
    );
    return HttpGetResponse(_response);
  }
}