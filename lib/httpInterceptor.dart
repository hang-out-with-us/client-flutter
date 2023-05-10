import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpInterceptor extends Interceptor {
  final dio = Dio();
  var _storage = const FlutterSecureStorage();

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // access 토큰 만료 에러시 재발급 요청
    if (err.response?.statusMessage == "EXPIRED_ACCESS_TOKEN") {
      _refresh();
    }
    super.onError(err, handler);
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    //인증 정보 header에 추가
    options = await _addTokenInHeader(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  _refresh() async {
    var res = await dio.post(dotenv.env["REFRESH_TOKEN_URL"]!);
    var data = res.data;
    String token = data["token"];
    String refreshToken = data["refreshToken"];
    await _storage.write(key: "token", value: token);
    await _storage.write(key: "refreshToken", value: refreshToken);
  }

  Future<RequestOptions> _addTokenInHeader(RequestOptions options) async {
    String? token = await _storage.read(key: "token");
    if (token != null) {
      options.headers["Authorization"] = "Bearer " + token;
    }
    String? refreshToken = await _storage.read(key: "refreshToken");
    if (refreshToken != null) {
      options.headers["RefreshToken"] = refreshToken;
    }
    return options;
  }
}
