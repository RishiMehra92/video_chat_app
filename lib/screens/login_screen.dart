import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_chat_app/providers/auth_provider.dart';
import 'package:video_chat_app/screens/user_list_screen.dart';
import 'package:video_chat_app/utils/validators.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserListScreen()));
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: validateEmail,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: validatePassword,
              ),
              const SizedBox(height: 20),
              if (authState.isLoading) const CircularProgressIndicator(),
              if (authState.error != null) Text(authState.error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ref.read(authProvider.notifier).login(emailController.text, passwordController.text);
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}