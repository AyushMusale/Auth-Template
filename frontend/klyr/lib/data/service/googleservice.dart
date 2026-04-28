import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class GoogleAuthService {
  final _appLinks = AppLinks();
  StreamSubscription? _sub;

  Future<Map<String, String>> signInWithGoogle() async {
    final completer = Completer<Map<String, String>>();

    // listen for deep link BEFORE opening browser
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'klyr' && uri.host == 'auth') {
        final accessToken = uri.queryParameters['access_token'];
        final refreshToken = uri.queryParameters['refresh_token'];

        if (accessToken != null && refreshToken != null) {
          completer.complete({
            'access_token': accessToken,
            'refresh_token': refreshToken,
          });
        }
        _sub?.cancel(); // stop listening after receiving tokens
      }
    });

    // open browser to your backend
    final uri = Uri.parse('http://10.0.2.2:3003/your-url/auth/google');
    await launchUrl(uri, mode: LaunchMode.externalApplication);

    return completer.future; // waits until deep link is received
  }

  void dispose() {
    _sub?.cancel();
  }
}
