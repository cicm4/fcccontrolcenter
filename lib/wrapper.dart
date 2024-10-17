// Importaciones necesarias para la gestión de autenticación y las vistas principales de la app.
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/database_service.dart';
import 'services/storage_service.dart';
import 'home/home.dart';
import 'login.dart';

class Wrapper extends StatelessWidget {
  final AuthService auth;
  final DBService dbs;
  final StorageService st;

  // Constructor que requiere los servicios de autenticación, base de datos y almacenamiento.
  const Wrapper({super.key, required this.auth, required this.dbs, required this.st});

  @override
  Widget build(BuildContext context) {
    // Se obtiene el estado del usuario actual.
    final User? user = Provider.of<User?>(context);

    // Si el usuario no está autenticado, se muestra la pantalla de inicio de sesión.
    // Si el usuario está autenticado, se redirige a la página principal (Home).
    if (user == null) {
      return Login(auth: auth);
    } else {
      return Home(dbs: dbs, st: st, auth: auth);
    }
  }
}
