import 'package:klyr/data/localdb/authdb.dart';
import 'package:klyr/data/repo/authrepo.dart';
import 'package:klyr/data/service/googleservice.dart';

class Authusecase {
  final Authrepo authrepo;
  final GoogleAuthService googleAuthService;
  Authusecase({required this.authrepo, required this.googleAuthService});

  Future<String> getOTP({required String email}) async {
    return await authrepo.getOTP(email: email);
  }

  Future<String> verifyOTP({required String email, required String otp}) async {
    return await authrepo.verifyOTP(email: email, otp: otp);
  }

  Future<String> googleAuth() async {
    try {
      final tokens = await googleAuthService.signInWithGoogle();
      await TokenStorage.saveTokens(
        accessToken: tokens['access_token']!,
        refreshToken: tokens['refreshToken']!,
      );
      return "success";
    } catch (e) {
      rethrow;
    }
  }
}
