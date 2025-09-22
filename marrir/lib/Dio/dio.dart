import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.242.120.219:8000/api/v1", // for your device
      // baseUrl: "http://127.0.0.1:8000/api/v1",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  DioClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ Load token from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("access_token");

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          // If request is FormData, don't override Content-Type
          if (options.data is FormData) {
            options.headers.remove("Content-Type");
          } else {
            options.headers["Content-Type"] = "application/json";
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Optional: handle global 401 here
          if (e.response?.statusCode == 401) {
            print("⚠️ Unauthorized - token might be expired");
          }
          return handler.next(e);
        },
      ),
    );
  }
}
