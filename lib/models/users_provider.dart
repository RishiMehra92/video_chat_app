import 'package:connectivity_plus/connectivity_plus.dart';  // Add dependency for connectivity
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_chat_app/models/user_model.dart';
import 'package:video_chat_app/services/api_service.dart';
import 'package:video_chat_app/services/hive_service.dart';

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) => UsersNotifier());

class UsersState {
  final bool isLoading;
  final String? error;
  final List<UserModel> users;

  UsersState({this.isLoading = false, this.error, this.users = const []});
}

class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier() : super(UsersState());

  Future<void> fetchUsers() async {
    state = UsersState(isLoading: true);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        final data = await ApiService.fetchUsers();
        final users = data.map((json) => UserModel.fromJson(json)).toList();
        await HiveService.cacheUsers(users);
        state = UsersState(users: users);
      } else {
        final cached = HiveService.getCachedUsers();
        state = UsersState(users: cached);
      }
    } catch (e) {
      state = UsersState(error: e.toString());
    }
  }
}