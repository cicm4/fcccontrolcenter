// Importaciones necesarias para el archivo login.dart
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:flutter/material.dart';

/// `Login` es un widget de estado completo (StatefulWidget) que se utiliza para la autenticación del usuario.
///
/// Este widget permite al usuario ingresar su correo electrónico y contraseña para iniciar sesión.
/// Si las credenciales son válidas, el usuario será autenticado usando Firebase.
class Login extends StatefulWidget {
  final AuthService auth;

  /// Constructor que recibe el servicio de autenticación (`auth`) para gestionar la lógica de inicio de sesión.
  const Login({super.key, required this.auth});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controladores para obtener los valores de los campos de correo electrónico y contraseña.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"), // Título de la aplicación en la barra superior.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo para introducir el correo electrónico
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            // Campo para introducir la contraseña
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true, // Ocultar el texto para mayor seguridad.
            ),
            const SizedBox(height: 20), // Espacio entre los campos y el botón.
            ElevatedButton(
              // Botón para iniciar sesión
              onPressed: () async {
                String email = _emailController.text;
                String password = _passwordController.text;

                // Llamada al servicio de autenticación para iniciar sesión con correo y contraseña
                bool? success = await widget.auth.signInEmailAndPass(
                  emailAddress: email,
                  password: password,
                );

                if (success == true) {
                  // Si el inicio de sesión es exitoso, se puede redirigir al usuario a otra página.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inicio de sesión exitoso')),
                  );
                } else {
                  // Si el inicio de sesión falla, se muestra un mensaje de error.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al iniciar sesión')),
                  );
                }
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
