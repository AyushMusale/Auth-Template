class Authstate {
  final bool isLoading;
  final bool isError;
  final String message;
  final String? email;

  const Authstate({
    required this.isLoading,
    required this.isError,
    required this.message,
    this.email,
  });
}

class AuthInitialstate extends Authstate {
  AuthInitialstate()
    : super(isError: false, isLoading: false, message: "initializing");
}
