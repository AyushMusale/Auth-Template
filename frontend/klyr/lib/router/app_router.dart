import 'package:go_router/go_router.dart';
import 'package:klyr/presentation/auth/authpage.dart';
import 'package:klyr/presentation/auth/otppage.dart';

final router = GoRouter(
  initialLocation: "/auth",
  routes: [
    GoRoute(
      path: '/auth',
      name: "authpage",
      builder: (context, state) => const Authpage(),
    ),
    GoRoute(
      path: '/otp',
      name: "otppage",
      builder: (context, state) {
        final email = state.extra as String? ?? "";
        return OtpPage(email: email);
      },
    ),
  ],
);
