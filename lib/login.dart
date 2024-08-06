// Required imports for login.dart
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:flutter/material.dart';


class Login extends StatefulWidget {
  final AuthService auth;
  const Login({super.key, required this.auth});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text;
                String password = _passwordController.text;
                bool? success = await widget.auth.signInEmailAndPass(
                  emailAddress: email,
                  password: password,
                );
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
