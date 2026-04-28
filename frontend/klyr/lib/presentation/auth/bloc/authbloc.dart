import 'package:klyr/data/localdb/authdb.dart';
import 'package:klyr/data/repo/authrepo.dart';
import 'package:klyr/data/service/googleservice.dart';
import 'package:klyr/domain/usecase/authusecase.dart';
import 'package:klyr/presentation/auth/bloc/authevent.dart';
import 'package:klyr/presentation/auth/bloc/authstate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Authbloc extends Bloc<Authevent, Authstate> {
  final Authusecase _usecase;

  Authbloc({Authusecase? usecase})
    : _usecase = usecase ?? Authusecase(authrepo: Authrepo(), googleAuthService: GoogleAuthService()),
      super(AuthInitialstate()) {
    on<GetOTPEvent>(_onGetOtp);
    on<VerifyOTPEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
    on<GoogleAuthEvent>(_onGoogleAuth);
  }

  Future<void> _onGoogleAuth(GoogleAuthEvent event, Emitter<Authstate> emit) async{
    emit(const Authstate(isLoading: true, isError: false, message: "loading"));
    try {
      final message = await _usecase.googleAuth();
      if(message == "success"){
        emit(
        Authstate(
          isLoading: false,
          isError: false,
          message: "success",
        ),
      );
      }
      else{
        emit(
        Authstate(
          isLoading: false,
          isError: true,
          message: "failure",
        ),
      );
      }
    } catch (e) {
      emit(Authstate(isLoading: false, isError: true, message: e.toString()));
    }
  }

  Future<void> _onGetOtp(GetOTPEvent event, Emitter<Authstate> emit) async {
    emit(const Authstate(isLoading: true, isError: false, message: "loading"));

    try {
      final email = await _usecase.getOTP(email: event.email);
      emit(
        Authstate(
          isLoading: false,
          isError: false,
          message: "otp-sent",
          email: email,
        ),
      );
    } catch (e) {
      emit(Authstate(isLoading: false, isError: true, message: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOTPEvent event,
    Emitter<Authstate> emit,
  ) async {
    emit(
      Authstate(
        isLoading: true,
        isError: false,
        message: "loading",
        email: event.email,
      ),
    );

    try {
      final email = await _usecase.verifyOTP(
        email: event.email,
        otp: event.otp,
      );
      emit(
        Authstate(
          isLoading: false,
          isError: false,
          message: "otp-verified",
          email: email,
        ),
      );
    } catch (e) {
      emit(
        Authstate(
          isLoading: false,
          isError: true,
          message: e.toString(),
          email: event.email,
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<Authstate> emit) async {
    emit(const Authstate(isLoading: true, isError: false, message: "loading"));
    await TokenStorage.clearTokens();
    emit(AuthInitialstate());
  }
}
