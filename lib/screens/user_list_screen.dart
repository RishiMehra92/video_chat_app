import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_chat_app/providers/users_provider.dart';
import 'package:video_chat_app/screens/video_call_screen.dart';

import 'agora_video_call_screen.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersProvider);
    ref.read(usersProvider.notifier).fetchUsers();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body:
      // usersState.isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     : usersState.error != null
      //     ? Center(child: Text(usersState.error!))
      //     :
      ListView.builder(
        itemCount: usersState.users.length,
        itemBuilder: (context, index) {
          final user = usersState.users[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
            title: Text('${user.firstName} ${user.lastName}'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgoraVideoCallScreen())),
          );
        },
      ),
    );
  }
}