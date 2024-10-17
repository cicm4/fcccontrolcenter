import 'package:fcccontrolcenter/home/home.dart';
import 'package:fcccontrolcenter/login.dart';
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:flutter/widgets.dart';

// Mapa que define las rutas de la aplicación y sus respectivas pantallas.
Map<String, WidgetBuilder> getAppRoutes(
    AuthService auth, DBService dbs, StorageService st) {
  return {
    // Ruta para la pantalla principal del administrador.
    '/home': (context) => Home(dbs: dbs, st: st, auth: auth),
    // Ruta para la pantalla de inicio de sesión.
    '/login': (context) => Login(auth: auth)
  };
}
