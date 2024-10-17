// Esta clase es un servicio general de base de datos.
// NO utilizará ninguna otra clase de servicio y NO tendrá ninguna funcionalidad específica.
// Solo contendrá métodos que interactúan directamente con la base de datos.
// Métodos específicos, como "saveNewPhotoToDB", NO forman parte de esta clase, ya que no es un servicio de base de datos especializado.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// `DBService`: Clase de servicio general para interactuar con Firestore.
/// Provee métodos para realizar las operaciones básicas de la base de datos.
class DBService {
  FirebaseFirestore db;

  /// Constructor sin parámetros que inicializa una instancia de Firestore.
  DBService() : db = FirebaseFirestore.instance;

  /// Constructor con una instancia de Firestore personalizada.
  DBService.withDB(this.db);

  // La clase ofrece 4 funciones básicas:
  // 1. Agregar datos a la base de datos.
  // 2. Eliminar datos de la base de datos.
  // 3. Obtener datos de la base de datos.
  // 4. Confirmar la existencia de datos en la base de datos.

  /// Verifica si un documento específico existe en la base de datos.
  ///
  /// Esta función verifica si un documento específico existe en la base de datos en una ruta especificada.
  /// Requiere un nombre de documento y una ruta como parámetros.
  ///
  /// @param data El nombre del documento que se va a verificar en la base de datos.
  /// @param path La ruta en la base de datos donde se espera que esté el documento.
  ///
  /// @return Un `Future` que se completa con un booleano. Devuelve `true` si el documento existe, `false` de lo contrario.
  Future<bool> isDataInDB({required data, required String path}) async {
    try {
      // Verifica si los datos no son nulos
      if (data != null) {
        // Obtiene el documento desde la base de datos
        final doc = await getFromDB(path: path, data: data);

        // Si el documento existe, devuelve `true`
        if (doc != null) {
          return true;
        }
      } else {
        // Si los datos son nulos, devuelve `false`
        return false;
      }
    } catch (e) {
      // Si ocurre un error, imprime el error si está en modo depuración y devuelve `false`
      if (kDebugMode) {
        print(e);
      }
    }
    // Si los datos no se encuentran o ocurre un error, devuelve `false`
    return false;
  }

  /// Obtiene datos de la base de datos.
  ///
  /// Esta función recupera datos de una ruta especificada en la base de datos.
  /// Requiere una ruta y un nombre de documento como parámetros.
  ///
  /// @param path La ruta en la base de datos de donde se van a recuperar los datos.
  /// @param data El documento específico que se va a recuperar de la base de datos.
  ///
  /// @return Un `Future` que se completa con un `Map` que contiene los datos, o `null` si ocurre un error o no se encuentran los datos.
  Future<Map<String, dynamic>?> getFromDB(
      {required String path, required String data}) async {
    try {
      // Recupera el documento de la base de datos
      final doc = await db.collection(path).doc(data).get();

      // Devuelve los datos del documento
      return doc.data();
    } catch (e) {
      // Si está en modo depuración, imprime el error
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error al obtener datos: $e, ruta: $path, datos: $data');
      }
    }
    // Si ocurre un error, devuelve `null`
    return null;
  }

  /// Agrega una entrada a la base de datos.
  ///
  /// Esta función intenta agregar una nueva entrada en una ruta especificada en la base de datos.
  /// Requiere una ruta y una entrada como parámetros. La entrada debe ser un `Map` que represente los campos del documento.
  ///
  /// @param path La ruta en la base de datos donde se agregará la nueva entrada.
  /// @param entry Un `Map` que representa los campos del documento.
  ///
  /// @return Un `Future` que se completa con un booleano. Devuelve `true` si la entrada se agrega exitosamente, `false` de lo contrario.
  Future<bool> addEntryToDB(
      {required String path,
      required Map<String, dynamic> entry}) async {
    try {
      // Agrega el nuevo documento a la base de datos
      await db.collection(path).add(entry);
      // Si el documento se agrega correctamente, devuelve `true`
      return true;
    } catch (e) {
      // Si ocurre un error, imprime el error si está en modo depuración
      if (kDebugMode) {
        print(e.toString());
      }
    }
    // Si ocurre un error, devuelve `false`
    return false;
  }

  /// Agrega una entrada a la base de datos con un nombre específico.
  ///
  /// Esta función intenta agregar una nueva entrada con un nombre específico en una ruta especificada.
  /// Es similar a `addEntryToDB`, pero permite especificar el ID del documento en lugar de generarlo automáticamente.
  ///
  /// @param path La ruta en la base de datos donde se agregará la nueva entrada.
  /// @param entry Un `Map` que representa los campos del documento.
  /// @param name El ID del documento.
  ///
  /// @return Un `Future` que se completa con un booleano. Devuelve `true` si la entrada se agrega exitosamente, `false` de lo contrario.
  Future<bool> addEntryToDBWithName(
      {required String path,
      required Map<String, dynamic> entry,
      required String name}) async {
    try {
      // Agrega el nuevo documento a la base de datos con el nombre especificado como ID
      await db.collection(path).doc(name).set(entry);
      // Si el documento se agrega correctamente, devuelve `true`
      return true;
    } catch (e) {
      // Si ocurre un error, imprime el error si está en modo depuración
      if (kDebugMode) {
        print(e.toString());
      }
    }
    // Si ocurre un error, devuelve `false`
    return false;
  }

  /// Elimina un documento de la base de datos.
  ///
  /// Esta función intenta eliminar un documento de una ruta especificada en la base de datos.
  /// Requiere una ruta y un nombre de documento como parámetros.
  ///
  /// @param path La ruta en la base de datos donde se encuentra el documento.
  /// @param data El nombre del documento que se va a eliminar.
  ///
  /// @return Un `Future` que se completa con un booleano. Devuelve `true` si el documento se elimina exitosamente, `false` de lo contrario.
  Future<bool> deleteInDB({required String path, required String data}) async {
    try {
      // Intenta eliminar el documento de la base de datos
      await db.collection(path).doc(data).delete();
      // Si el documento se elimina correctamente, devuelve `true`
      return true;
    } catch (e) {
      // Si ocurre un error, imprime el error si está en modo depuración
      if (kDebugMode) {
        print(e.toString());
      }
    }
    // Si ocurre un error o el documento no se encuentra, devuelve `false`
    return false;
  }

  /// Obtiene una lista de documentos que coinciden con una variable en la base de datos.
  ///
  /// Esta función recupera una lista de documentos de una ruta específica donde un campo coincide con un valor determinado.
  ///
  /// @param path La ruta en la base de datos.
  /// @param variable El campo que se va a filtrar.
  /// @param value El valor que debe coincidir.
  ///
  /// @return Un `Future` que se completa con una lista de mapas. Cada mapa representa los datos de un documento.
  Future<List<Map<String, dynamic>>?> getListWithVariableFromDB(
      {required String path, required String variable, required String value}) async {
    try {
      List<Map<String, dynamic>> list = [];
      QuerySnapshot querySnapshot = await db.collection(path).where(variable, isEqualTo: value).get();
      for (var doc in querySnapshot.docs) {
        list.add(doc.data() as Map<String, dynamic>);
      }
      return list;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error al obtener la lista: $e');
      }
    }
    return null;
  }

  /// Recupera todos los documentos de una colección especificada en la base de datos.
  ///
  /// Este método obtiene todos los documentos de una ruta dada (colección) en la base de datos y los devuelve como una lista de mapas.
  /// Cada mapa representa los datos de un documento dentro de la colección.
  ///
  /// @param path La ruta de la colección de la cual se recuperarán los documentos.
  ///
  /// @return Un `Future` que se completa con una lista de mapas. Si ocurre un error o la colección está vacía, puede devolver `null` o una lista vacía.
  Future<List<Map<String, dynamic>>?> getCollection({required String path}) async {
    try {
      return await db.collection(path).get().then((QuerySnapshot querySnapshot) {
        List<Map<String, dynamic>> list = [];
        for (var doc in querySnapshot.docs) {
          list.add(doc.data() as Map<String, dynamic>);
        }
        return list;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error al obtener la colección: $e');
      }
    }
    return null;
  }

  /// Actualiza un documento en la base de datos.
  ///
  /// Esta función intenta actualizar un documento en la base de datos en una ruta especificada.
  /// Requiere una ruta y un `Map` con los campos a actualizar.
  ///
  /// @param path La ruta en la base de datos donde se encuentra el documento.
  /// @param data Un `Map` que representa los campos que se van a actualizar.
  ///
  /// @return Un `Future` que se completa sin valor de retorno. Si ocurre un error durante la actualización, el método puede lanzar una excepción si está en modo depuración.
  Future<void> updateDocument(
      {required String path, required Map<String, dynamic> data}) async {
    try {
      await db.doc(path).update(data);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error al actualizar el documento: $e');
      }
    }
  }
  // fin de la clase
}
