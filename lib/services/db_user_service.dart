import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:flutter/foundation.dart';

class DBUserService {

/// Retrieves all user documents from the 'users' collection in the database.
///
/// This method utilizes the [DBService] to fetch all documents from the 'users' collection. It returns a list of maps, where each map represents a single user's data.
///
/// @param dbs An instance of [DBService] used to access the database.
///
/// @return A Future that completes with a list of maps, each containing the data of a single user document. If an error occurs during the fetch, the method may return null or throw an exception if in debug mode.
///
/// Usage example:
/// ```dart
/// DBUserService dbUserService = DBUserService();
/// dbUserService.getAllUsers(dbServiceInstance).then((List<Map<String, dynamic>>? users) {
///   if (users != null) {
///     for (var user in users) {
///       print(user);
///     }
///   }
/// }).catchError((error) {
///   print('An error occurred: $error');
/// });
/// ```
  static Future<List<Map<String, dynamic>>?> getAllUsers(DBService dbs) async {
    //get all users from the database
    try {
      return dbs.getCollection(path: 'users');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error getting collection: $e');
      }
    }
    return null;
  }

/// Updates a specific user document in the 'users' collection of the database.
///
/// This method takes a user ID and a map of data to update the corresponding user document in the database. It utilizes the [DBService] to perform the update operation.
///
/// @param dbs An instance of [DBService] used to access and update the database.
/// @param uid The unique identifier of the user document to be updated.
/// @param data A map containing the key-value pairs to be updated in the user document.
///
/// @return A Future that completes with void. If an error occurs during the update, the method may throw an exception if in debug mode.
///
/// Usage example:
/// ```dart
/// DBUserService dbUserService = DBUserService();
/// Map<String, dynamic> userData = {'name': 'Jane Doe', 'email': 'jane.doe@example.com'};
/// dbUserService.updateUser(dbServiceInstance, 'user123', userData).then((_) {
///   print('User updated successfully.');
/// }).catchError((error) {
///   print('An error occurred: $error');
/// });
/// ```
  static Future<void> updateUser(DBService dbs, String uid, Map<String, dynamic> data) async {
    //update user data in the database
    try {
      await dbs.updateDocument(path: 'users/$uid', data: data);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error updating user: $e');
      }
    }
  }

  static Future<void> removeUser(DBService dbs, String uid) async {
    //remove user from the database
    try {
      await dbs.deleteInDB(path: 'users', data: uid);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        throw Exception('Error deleting user: $e');
      }
    }
  }
}
