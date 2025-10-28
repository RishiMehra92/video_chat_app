import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_chat_app/services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({this.isLoading = false, this.error, this.isAuthenticated = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final token = await ApiService.login(email, password);
      if (token != null) {
        state = AuthState(isAuthenticated: true);
        print('Mock Push: Incoming video call!');
      } else {
        state = AuthState(error: 'Invalid credentials');
      }
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }
}