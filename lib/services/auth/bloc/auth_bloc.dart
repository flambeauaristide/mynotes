import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    //send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        emit(const AuthStateNeedVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    //initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });

    //login
    on<AuthEventLogin>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: true,
            loadingText: 'Please wait while I log you in'));
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.login(
            email: email,
            password: password,
          );

          if (!user.isEmailVerified) {
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(const AuthStateNeedVerification(isLoading: false));
          } else {
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(AuthStateLoggedIn(user: user, isLoading: false));
          }
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );

    //logout
    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          await provider.logout();
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );
  }
}
