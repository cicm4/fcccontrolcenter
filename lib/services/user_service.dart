import 'package:firebase_auth/firebase_auth.dart';

/// `UserService`: Clase que maneja el acceso al usuario actual y el flujo de cambios de estado de autenticación.
/// Utiliza Firebase Authentication para gestionar a los usuarios.
class UserService {
  
  /// Flujo de cambios de estado de autenticación.
  ///
  /// Este `Stream` emite un evento cada vez que el usuario inicia o cierra sesión.
  /// Se utiliza para detectar automáticamente los cambios en el estado de autenticación.
  final Stream<User?> userStream = FirebaseAuth.instance.authStateChanges();

  /// Instancia del usuario actual.
  ///
  /// Esta es la instancia del usuario que ha iniciado sesión actualmente.
  /// Si ningún usuario ha iniciado sesión, será `null`.
  final User? user = FirebaseAuth.instance.currentUser;
}
