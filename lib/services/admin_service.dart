import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/user_service.dart';

/// `AdminService`: Clase que proporciona métodos para manejar operaciones relacionadas con administradores.
///
/// Incluye un método estático `isAdmin` que verifica si un usuario es administrador.
///
/// El método `isAdmin` recibe dos parámetros:
/// - `userService`: Una instancia de `UserService` que proporciona acceso al usuario actual.
/// - `dbService`: Una instancia de `DBService` que proporciona acceso a la base de datos.
///
/// El método devuelve un `Future<bool>` que se completa con `true` si el usuario es administrador, y `false` en caso contrario.
///
/// Ejemplo de uso:
/// ```dart
/// bool isAdmin = await AdminService.isAdmin(userService: userService, dbService: dbService);
/// ```
///
/// Nota: Esta clase requiere instancias de `DBService` y `UserService` para su funcionamiento.
class AdminService {
  /// `isAdmin`: Método estático en la clase `AdminService`.
  ///
  /// Este método verifica si un usuario es administrador consultando la base de datos.
  ///
  /// Parámetros:
  /// - `userService`: Instancia de `UserService` para obtener acceso al usuario actual.
  /// - `dbService`: Instancia de `DBService` para acceder a la base de datos.
  ///
  /// Devuelve un `Future<bool>` que se completa con `true` si el usuario es administrador y con `false` en caso contrario.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// bool isAdmin = await AdminService.isAdmin(userService: userService, dbService: dbService);
  /// ```
  static Future<bool> isAdmin(
      {required UserService userService, required DBService dbService}) async {
    try {
      // Verifica si el usuario está registrado como administrador en la base de datos.
      bool isAdmin = await dbService.isDataInDB(
        data: userService.user!.uid, path: 'admin');
      
      // Si el usuario no es administrador, se cierra la sesión.
      if (!isAdmin) {
        AuthService.signOut();
      }
      return isAdmin;
    } catch (e) {
      // En caso de error, se cierra la sesión y se devuelve `false`.
      AuthService.signOut();
      return false;
    }
  }
}
