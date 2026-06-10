import "dart:convert";

import "package:http/http.dart" as http;
import "package:template/core/logger.dart";

/// 모든 네트워크 요청이 거쳐 가는 얇은 HTTP 래퍼.
/// 각 레포지토리는 이 클래스를 통해 서버와 통신한다.
/// 서버 주소를 바꾸려면 [kBaseUrl] 한 곳만 수정하면 된다.

const String kBaseUrl = "https://jsonplaceholder.typicode.com";

class ApiRequester {
  ApiRequester({this.baseUrl = kBaseUrl});

  final String baseUrl;

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse("$baseUrl$path").replace(queryParameters: query);
    logger.d("GET $uri");
    final response = await http.get(uri);
    return _handle(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse("$baseUrl$path");
    logger.d("POST $uri");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  dynamic _handle(http.Response response) {
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => "ApiException($statusCode): $body";
}
