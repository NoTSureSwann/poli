import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Klinik App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selamat Datang di Klinik App'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement login
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
