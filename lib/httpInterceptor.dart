import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HttpInterceptor extends Interceptor {
  final dio = Dio();
  var _storage = const FlutterSecureStorage();

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(err.response);
    var errCode = err.response.toString();
    // access 토큰 만료 에러시 재발급 요청
    if (errCode as String == "EXPIRED_ACCESS_TOKEN") {
      print("access token expired");
      _refresh();
    } else if (errCode as String == "INVALID_TOKEN") {
      //TODO: 로그인 페이지로 이동
    }
    super.onError(err, handler);
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String? jwt = await _storage.read(key: "token");
    String? refreshToken = await _storage.read(key: "refreshToken");

    //api 요청 전 토큰 상태 확인
    if (jwt != null && refreshToken != null) {
      Map<String, dynamic> jwtDecoded = JwtDecoder.decode(jwt);
      Map<String, dynamic> refreshTokenDecoded =
          JwtDecoder.decode(refreshToken);

      if (jwtDecoded["exp"] < DateTime.now().millisecondsSinceEpoch / 1000) {
        if (refreshTokenDecoded["exp"] <
            DateTime.now().millisecondsSinceEpoch / 1000) {
          //TODO: 로그인 페이지로 이동
        } else {
          //access 토큰 재발급
          await _refresh();
        }
      }
    }
    //인증 정보 header에 추가
    if (!options.path.startsWith(await dotenv.env['SERVER_URL']! + "auth/")) {
      options = await _addTokenInHeader(options);
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  _refresh() async {
    String xRefreshToken = await _storage.read(key: "refreshToken") as String;
    var res = await dio.get(dotenv.env["REFRESH_TOKEN_URL"]!,
        options: Options(headers: {"X-Refresh-Token": xRefreshToken}));
    var data = res.data;
    String token = data["token"];
    String refreshToken = data["refreshToken"];
    await _storage.write(key: "token", value: token);
    await _storage.write(key: "refreshToken", value: refreshToken);
    print("refreshed");
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
