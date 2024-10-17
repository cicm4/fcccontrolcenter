// Importaciones necesarias para inicializar Firebase, manejar la autenticación, y temas personalizados.
import 'package:fcccontrolcenter/firebase_options.dart';
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:fcccontrolcenter/shared/shared/routes.dart';
import 'package:fcccontrolcenter/shared/shared/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/database_service.dart';
import 'services/user_service.dart';
import 'services/storage_service.dart';

import 'wrapper.dart';

void main() async {
  // Asegura que los widgets de Flutter estén vinculados antes de inicializar Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase con las opciones predeterminadas.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    runApp(const MyApp());
  } catch (e) {
    // Si hay un error durante la inicialización, se imprime en modo debug.
    if (kDebugMode) {
      print('Falló la inicialización de Firebase: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se inicializan los servicios principales: base de datos, autenticación, usuarios y almacenamiento.
    DBService dbs = DBService();
    AuthService auth = AuthService(dbs);
    UserService us = UserService();
    StorageService st = StorageService();

    return StreamProvider<User?>.value(
      // Se provee un Stream para monitorear el estado del usuario autenticado en la app.
      value: us.userStream,
      initialData: us.user,
      child: MaterialApp(
        // Configura las rutas de la aplicación.
        routes: getAppRoutes(auth, dbs, st),
        // Aplica el tema general a la aplicación.
        theme: generalTheme,
        // Definir la página inicial según el estado de autenticación.
        home: Wrapper(auth: auth, dbs: dbs, st: st),
      ),
    );
  }
}
