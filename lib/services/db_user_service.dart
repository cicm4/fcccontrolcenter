import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:flutter/foundation.dart';

/// `DBUserService`: Clase que proporciona métodos para interactuar con los datos de usuarios en la base de datos.
///
/// Esta clase utiliza la clase `DBService` para realizar operaciones CRUD sobre los documentos de usuarios en Firestore.
class DBUserService {

  /// Recupera todos los documentos de usuarios de la colección 'users' en la base de datos.
  ///
  /// Este método utiliza [DBService] para obtener todos los documentos de la colección 'users'. Devuelve una lista de mapas, donde cada mapa representa los datos de un usuario.
  ///
  /// @param dbs Una instancia de [DBService] que se utiliza para acceder a la base de datos.
  ///
  /// @return Un `Future` que se completa con una lista de mapas, cada uno de los cuales contiene los datos de un documento de usuario.
  /// Si ocurre un error durante la operación, el método puede devolver `null` o lanzar una excepción en modo depuración.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// DBUserService dbUserService = DBUserService();
  /// dbUserService.getAllUsers(dbServiceInstance).then((List<Map<String, dynamic>>? users) {
  ///   if (users != null) {
  ///     for (var user in users) {
  ///       print(user);
  ///     }
  ///   }
  /// }).catchError((error) {
  ///   print('Ocurrió un error: $error');
  /// });
  /// ```
  static Future<List<Map<String, dynamic>>?> getAllUsers(DBService dbs) async {
    // Obtiene todos los usuarios de la base de datos
    try {
      return dbs.getCollection(path: 'users');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error al obtener la colección: $e');
      }
    }
    return null;
  }

  /// Actualiza un documento de usuario específico en la colección 'users' de la base de datos.
  ///
  /// Este método toma un ID de usuario y un mapa de datos para actualizar el documento correspondiente en la base de datos.
  /// Utiliza [DBService] para realizar la operación de actualización.
  ///
  /// @param dbs Una instancia de [DBService] utilizada para acceder y actualizar la base de datos.
  /// @param uid El identificador único del usuario cuyo documento se va a actualizar.
  /// @param data Un mapa que contiene los pares clave-valor que se actualizarán en el documento del usuario.
  ///
  /// @return Un `Future` que se completa sin valor de retorno. Si ocurre un error durante la actualización, el método puede lanzar una excepción en modo depuración.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// DBUserService dbUserService = DBUserService();
  /// Map<String, dynamic> userData = {'name': 'Jane Doe', 'email': 'jane.doe@example.com'};
  /// dbUserService.updateUser(dbServiceInstance, 'user123', userData).then((_) {
  ///   print('Usuario actualizado correctamente.');
  /// }).catchError((error) {
  ///   print('Ocurrió un error: $error');
  /// });
  /// ```
  static Future<void> updateUser(DBService dbs, String uid, Map<String, dynamic> data) async {
    // Actualiza los datos del usuario en la base de datos
    try {
      await dbs.updateDocument(path: 'users/$uid', data: data);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error al actualizar el usuario: $e');
      }
    }
  }

  /// Elimina un documento de usuario específico de la colección 'users' en la base de datos.
  ///
  /// Este método toma un ID de usuario y elimina el documento correspondiente de la base de datos utilizando [DBService].
  ///
  /// @param dbs Una instancia de [DBService] utilizada para acceder a la base de datos.
  /// @param uid El identificador único del usuario cuyo documento se va a eliminar.
  ///
  /// @return Un `Future` que se completa sin valor de retorno. Si ocurre un error durante la eliminación, el método puede lanzar una excepción en modo depuración.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// DBUserService dbUserService = DBUserService();
  /// dbUserService.removeUser(dbServiceInstance, 'user123').then((_) {
  ///   print('Usuario eliminado correctamente.');
  /// }).catchError((error) {
  ///   print('Ocurrió un error: $error');
  /// });
  /// ```
  static Future<void> removeUser(DBService dbs, String uid) async {
    // Elimina al usuario de la base de datos
    try {
      await dbs.deleteInDB(path: 'users', data: uid);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error al eliminar el usuario: $e');
      }
    }
  }
}
