abstract class Authevent {}

class GetOTPEvent extends Authevent {
  final String email;
  GetOTPEvent({required this.email});
}

class VerifyOTPEvent extends Authevent {
  final String email;
  final String otp;

  VerifyOTPEvent({required this.email, required this.otp});
}

class GoogleAuthEvent extends Authevent{}
class LogoutEvent extends Authevent {}
