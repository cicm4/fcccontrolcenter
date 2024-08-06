import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fcccontrolcenter/data/help.dart';
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class HelpService {
  /// Fetches all helps from the database.
  ///
  /// This function retrieves all help requests from the 'helps' collection
  /// in Firestore. It returns a list of `HelpVar` objects representing each help request.
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

  /// Updates the status of a help request in the database.
  ///
  /// This function updates the status of a help request identified by `helpId`.
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

  /// Retrieves the download URL for the attached file of a help request.
  ///
  /// This function returns the download URL for a file stored in Firebase Storage.
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

  /// Downloads the attached file of a help request and returns it as Uint8List.
  ///
  /// This function downloads a file from Firebase Storage to the user's device
  /// and returns the file data for preview.
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
