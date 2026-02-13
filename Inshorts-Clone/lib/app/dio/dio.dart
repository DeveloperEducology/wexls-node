// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GetDio {
  bool loggedIn = false;
  GetDio._();

  static Dio getDio() {
    Dio dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          options.connectTimeout = const Duration(seconds: 90);
          options.receiveTimeout = const Duration(seconds: 90);
          options.sendTimeout = const Duration(seconds: 90);
          options.followRedirects = true;
          
          // Use CORS proxy for web, direct API for mobile
          if (kIsWeb) {
            options.baseUrl = "https://api.allorigins.win/raw?url=https://twitterapi-node.onrender.com/";
          } else {
            options.baseUrl = "https://twitterapi-node.onrender.com/";
          }

          handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          handler.next(response);
        },
        onError: (DioException dioError, ErrorInterceptorHandler handler) {
          if (dioError.type == DioExceptionType.unknown) {
            if (dioError.message?.contains('SocketException') ?? false) {
              // ignore: avoid_print
              print("no internet");
            }
          }

          handler.next(dioError);
        },
      ),
    );
    return dio;
  }
}
