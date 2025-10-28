import 'package:hive/hive.dart';
import 'package:video_chat_app/models/user_model.dart';

class HiveService {
  static late Box<UserModel> userBox;

  static Future<void> init() async {
    userBox = await Hive.openBox<UserModel>('users');
  }

  static Future<void> cacheUsers(List<UserModel> users) async {
    await userBox.clear();
    for (var user in users) {
      await userBox.put(user.id, user);
    }
  }

  static List<UserModel> getCachedUsers() {
    return userBox.values.toList();
  }
}