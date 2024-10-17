// Esta clase se utiliza para gestionar el almacenamiento de archivos utilizando Firebase Storage.
// Utiliza el paquete firebase_storage y tiene la finalidad de actuar como un servicio de almacenamiento general.
// Métodos como "guardarFotoEnST" no formarían parte de esta clase, ya que no corresponden a un servicio de almacenamiento general.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class StorageService {
  final st = FirebaseStorage.instance;

  /// Sube un archivo a Firebase Storage.
  ///
  /// Este método sube un archivo a una ruta especificada en Firebase Storage.
  /// Requiere un archivo (`file`), un nombre de archivo (`data`) y una ruta (`path`) como parámetros.
  /// Nota: el parámetro `path` no debe terminar con una '/'.
  ///
  /// @param file Archivo a ser subido.
  /// @param data Nombre del archivo.
  /// @param path Ruta en Firebase Storage donde se almacenará el archivo.
  ///
  /// @return Un `Future` que completa con un booleano. Retorna `true` si el archivo se sube correctamente, `false` en caso contrario.
  Future<bool> addFile(
      {required File file, required String data, required String path}) async {
    try {
      // Crear una referencia al archivo en Firebase Storage
      final fileRef = st.ref().child('$path/$data');
      // Subir el archivo a Firebase Storage
      await fileRef.putFile(file);
      // Si el archivo se sube correctamente, retorna true
      return true;
    } catch (e) {
      // Si ocurre un error, imprimir el error en modo debug
      if (kDebugMode) {
        print(e.toString());
      }
    }
    // Si ocurre un error o no se encuentra el archivo, retorna false
    return false;
  }

  /// Verifica si un archivo existe en Firebase Storage.
  ///
  /// Este método verifica si un archivo existe en una ruta específica de Firebase Storage.
  /// Requiere un nombre de archivo (`data`) y una ruta (`path`) como parámetros.
  ///
  /// @param data Nombre del archivo.
  /// @param path Ruta en Firebase Storage donde se encuentra el archivo.
  ///
  /// @return Un `Future` que completa con un booleano. Retorna `true` si el archivo existe, `false` en caso contrario.
  Future<bool> isFileInST({required String data, required String path}) async {
    try {
      final ref = st.ref().child('$path/$data');
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un archivo de Firebase Storage.
  ///
  /// Este método elimina un archivo de una ruta especificada en Firebase Storage.
  /// Requiere un nombre de archivo (`data`) y una ruta (`path`) como parámetros.
  ///
  /// @param data Nombre del archivo.
  /// @param path Ruta en Firebase Storage donde se encuentra el archivo.
  ///
  /// @return Un `Future` que completa cuando la operación de eliminación se realiza.
  Future deleteFileFromST({required String data, required String path}) async {
    try {
      final ref = st.ref().child('$path/$data');
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return false;
  }

  /// Obtiene un archivo de Firebase Storage.
  ///
  /// Este método recupera un archivo de Firebase Storage en la ruta especificada (`path`) y (`data`).
  /// Devuelve el archivo como `Uint8List`.
  ///
  /// @param path Ruta del archivo en Firebase Storage.
  /// @param data Nombre del archivo.
  ///
  /// @return Si el archivo se recupera correctamente, se devuelve como `Uint8List`.
  /// Si no se encuentra el archivo o ocurre un error durante la recuperación, devuelve un `Uint8List` vacío.
  Future<Uint8List> getFileFromST(
      {required String path, required String data}) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      const oneMegabyte = 1024 * 1024;
      final pathRef = storageRef.child('$path/$data');
      if (kDebugMode) {
        print('Retrieving with final file path: $path/$data');
      }
      final Uint8List? dataList = await pathRef.getData(3 * oneMegabyte);
      return dataList ?? Uint8List(0);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return Uint8List(0);
  }

  /// Obtiene la URL de descarga de un archivo en Firebase Storage.
  ///
  /// Este método obtiene la URL de descarga de un archivo almacenado en Firebase Storage en la ruta especificada.
  ///
  /// @param path Ruta del archivo en Firebase Storage.
  /// @param data Nombre del archivo.
  ///
  /// @return Un `Future` que completa con un `String`. Retorna la URL de descarga si se obtiene correctamente, o `null` si ocurre un error.
  Future<String?> getFileURL(
      {required String path, required String data}) async {
    try {
      final url = await st.ref().child('$path/$data').getDownloadURL();
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file URL: $e');
      }
      return null;
    }
  }

  /// Escribe un archivo en la ruta especificada en Firebase Storage.
  ///
  /// Este método escribe un archivo desde el almacenamiento local en una ruta específica de Firebase Storage.
  ///
  /// @param dir Directorio donde se encuentra el archivo.
  /// @param file Archivo a escribir.
  /// @param path Ruta en Firebase Storage donde se almacenará el archivo.
  /// @param data Nombre del archivo.
  ///
  /// @return Un `Future` que completa con un booleano. Retorna `true` si la operación se completa correctamente, o `false` si ocurre un error.
  Future<bool> writeToFile(
      {required Directory dir,
      required File file,
      required String path,
      required String data}) async {
    try {
      st.ref('/$path/$data').writeToFile(file);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        return false;
      } else {
        return false;
      }
    }
    return true;
  }
}
