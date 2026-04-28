import 'package:klyr/network/authclient.dart';
import 'package:dio/dio.dart';
import 'package:klyr/data/localdb/authdb.dart';

class Authrepo {
  Future<String> getOTP({required String email}) async {
    try {
      final response = await Authclient.instance.post(
        "/auth/get-otp",
        data: {"email": email},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final message = data["message"];
        if (message == "success") {
          return data['email'];
        }
        if (message is String && message.isNotEmpty) {
          throw message;
        }
      }

      throw "server-error";
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map<String, dynamic>) {
        final message = body["message"];
        if (message is String && message.isNotEmpty) {
          throw message;
        }
      }
      throw "network-error";
    }
  }
  Future<String> verifyOTP({required String email, required String otp}) async {
    try {
      final response = await Authclient.instance.post(
        "/auth/verify",
        data: {"email": email, "otp": otp},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final message = data["message"];
        final tokens = data["tokens"];
        if (message == "success" && tokens is Map<String, dynamic>) {
          final accessToken = tokens["access_token"];
          final refreshToken = tokens["refresh_token"];

          if (accessToken is String && refreshToken is String) {
            await TokenStorage.saveTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            );
            return data["email"] as String? ?? email;
          }
        }
        if (message is String && message.isNotEmpty) {
          throw message;
        }
      }

      throw "server-error";
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map<String, dynamic>) {
        final message = body["message"];
        if (message is String && message.isNotEmpty) {
          throw message;
        }
      }
      throw "network-error";
    }
  }
}
