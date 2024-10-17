import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fcccontrolcenter/data/help.dart';
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:flutter/foundation.dart';

/// `HelpService` proporciona métodos para manejar las solicitudes de ayuda.
///
/// Estos métodos permiten realizar operaciones CRUD sobre las solicitudes de ayuda
/// en la base de datos y también manejar archivos asociados.
class HelpService {
  /// Obtiene todas las solicitudes de ayuda de la base de datos.
  ///
  /// Esta función recupera todas las solicitudes de ayuda de la colección 'adminNotification'
  /// en Firestore y las convierte en una lista de objetos `HelpVar`.
  static Future<List<HelpVar>?> getAllHelps({
    required DBService dbService,
  }) async {
    try {
      List<Map<String, dynamic>>? helpDataList =
          await dbService.getCollection(path: 'adminNotification');
      return helpDataList?.map((helpData) => HelpVar.fromMap(helpData)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching helps: $e');
      }
      return null;
    }
  }

  /// Actualiza el estado de una solicitud de ayuda en la base de datos.
  ///
  /// Utiliza `helpId` para identificar la solicitud y `newStatus` para actualizar
  /// su estado en la colección 'adminNotification'.
  static Future<void> updateHelpStatus({
    required DBService dbService,
    required String helpId,
    required String newStatus,
  }) async {
    try {
      await dbService.updateDocument(
        path: 'adminNotification/$helpId',
        data: {'status': newStatus},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating help status: $e');
      }
    }
  }

  /// Obtiene la URL de descarga del archivo adjunto a una solicitud de ayuda.
  ///
  /// Devuelve la URL de descarga para un archivo almacenado en Firebase Storage.
  static Future<String?> getFileDownloadURL({
    required StorageService storageService,
    required String helpId,
    required String fileName,
  }) async {
    try {
      return await storageService.getFileURL(
        path: 'helps/$helpId',
        data: fileName,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file URL: $e');
      }
      return null;
    }
  }

  /// Descarga el archivo adjunto de una solicitud de ayuda y lo guarda localmente.
  ///
  /// Descarga un archivo desde Firebase Storage al dispositivo del usuario
  /// y devuelve los datos del archivo (`Uint8List`) para su previsualización.
  static Future<Uint8List?> downloadFile({
    required String url,
    required String savePath,
  }) async {
    try {
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final file = File(savePath);
      await file.writeAsBytes(response.data);

      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      return null;
    }
  }
}
