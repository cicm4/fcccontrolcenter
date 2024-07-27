import 'dart:io';
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/scholarship.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

enum UrlFileType {
  matriculaURL,
  horarioURL,
  soporteURL,
  bankaccount,
}

class ScholarshipService {
  Scholarship? scholarship;
  final DBService dbService;
  final String uid;

  bool smartCycle = false;

  ScholarshipService._({this.scholarship, required this.dbService, required this.uid});

  static Future<ScholarshipService> create({required String uid, required DBService dbService}) async {
    try {
      var scholarshipService = ScholarshipService._(scholarship: null, dbService: dbService, uid: uid);
      await scholarshipService.configureScholarship();
      return scholarshipService;
    } catch (e) {
      throw Exception('Failed to create ScholarshipService: $e');
    }
  }

  Future<void> configureScholarship() async {
    Map<String, dynamic>? data = await _getScholarshipDataFromDB(uid);
    if (data != null) {
      scholarship = Scholarship.fromMap(data);
    } else {
      scholarship = Scholarship(
        uid: uid,
        gid: '',
        matriculaURL: '',
        horarioURL: '',
        soporteURL: '',
        bankaccount: '',
        matriculaURLName: '',
        horarioURLName: '',
        soporteURLName: '',
        bankaccountName: '',
        bankaccountURL: '',
        isBankDataFile: false,
      );
    }
  }

  Future<Map<String, dynamic>?> _getScholarshipDataFromDB(String uid) async {
    return await dbService.getFromDB(path: 'scholarships', data: uid);
  }

  getScholarshipData() {
    return scholarship?.getScholarshipData();
  }

  Future<Uint8List?> getURLFile({required UrlFileType fileType, required StorageService storageService}) async {
    try {
      String? path;
      String? data;
      switch (fileType) {
        case UrlFileType.matriculaURL:
          path = scholarship!.matriculaURL;
          data = scholarship!.matriculaURLName;
          break;
        case UrlFileType.horarioURL:
          path = scholarship!.horarioURL;
          data = scholarship!.horarioURLName;
          break;
        case UrlFileType.soporteURL:
          path = scholarship!.soporteURL;
          data = scholarship!.soporteURLName;
          break;
        case UrlFileType.bankaccount:
          path = scholarship!.bankaccountURL;
          data = scholarship!.bankaccountName;
          break;
        default:
          throw Exception('Invalid UrlFileType');
      }

      if (data != null && path != null) {
        return await storageService.getFileFromST(path: path, data: data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching file: $e');
    }
  }

  Future<String?> getURLFileURL({required UrlFileType fileType, required StorageService storageService}) async {
    try {
      String? path;
      String? data;
      switch (fileType) {
        case UrlFileType.matriculaURL:
          path = scholarship!.matriculaURL;
          data = scholarship!.matriculaURLName;
          break;
        case UrlFileType.horarioURL:
          path = scholarship!.horarioURL;
          data = scholarship!.horarioURLName;
          break;
        case UrlFileType.soporteURL:
          path = scholarship!.soporteURL;
          data = scholarship!.soporteURLName;
          break;
        case UrlFileType.bankaccount:
          path = scholarship!.bankaccountURL;
          data = scholarship!.bankaccountName;
          break;
        default:
          throw Exception('Invalid UrlFileType');
      }

      if (data != null && path != null) {
        return await storageService.getFileURL(path: path, data: data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching file url: $e');
    }
  }

  Future<Map<String, String>?> getURLFilePathAndData({required UrlFileType fileType, required StorageService storageService}) async {
    try {
      String? path;
      String? data;
      switch (fileType) {
        case UrlFileType.matriculaURL:
          path = scholarship!.matriculaURL;
          data = scholarship!.matriculaURLName;
          break;
        case UrlFileType.horarioURL:
          path = scholarship!.horarioURL;
          data = scholarship!.horarioURLName;
          break;
        case UrlFileType.soporteURL:
          path = scholarship!.soporteURL;
          data = scholarship!.soporteURLName;
          break;
        case UrlFileType.bankaccount:
          path = scholarship!.bankaccountURL;
          data = scholarship!.bankaccountName;
          break;
        default:
          throw Exception('Invalid UrlFileType');
      }

      if (data != null && path != null) {
        //map of path and data
        return {'path': path, 'data': data};
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching file url: $e');
    }
  }

  Future<String?> getURLFileData({required UrlFileType fileType, required StorageService storageService}) async {
    try {
      String? data;
      switch (fileType) {
        case UrlFileType.matriculaURL:
          data = scholarship!.matriculaURLName;
          break;
        case UrlFileType.horarioURL:
          data = scholarship!.horarioURLName;
          break;
        case UrlFileType.soporteURL:
          data = scholarship!.soporteURLName;
          break;
        case UrlFileType.bankaccount:
          data = scholarship!.bankaccountName;
          break;
        default:
          throw Exception('Invalid UrlFileType');
      }

      if (data != null) {
        return data;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching file url: $e');
    }
  }

  Future pickURLFileType() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.first.name;
        return [file, fileName];
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        throw Exception('Error getting file: $e');
      }
      return null;
    }
  }

  Future addFiledRequirement({
    required StorageService st,
    required UrlFileType type,
    required fileURL,
    required fileName,
  }) async {
    try {
      String fileType;
      String fileTypeName;

      var data = await getScholarshipData();

      switch (type) {
        case UrlFileType.matriculaURL:
          fileType = 'matriculaURL';
          fileTypeName = 'matriculaURLName';
          break;
        case UrlFileType.horarioURL:
          fileType = 'horarioURL';
          fileTypeName = 'horarioURLName';
          break;
        case UrlFileType.soporteURL:
          fileType = 'soporteURL';
          fileTypeName = 'soporteURLName';
          break;
        case UrlFileType.bankaccount:
          fileType = 'bankaccountURL';
          fileTypeName = 'bankaccountName';
          break;
      }
      data[fileType] = 'scholarships/$uid/$fileType';
      data[fileTypeName] = fileName;

      await st.addFile(path: 'scholarships/$uid/$fileType', file: fileURL, data: fileName);

      await dbService.addEntryToDBWithName(path: 'scholarships', entry: data, name: uid);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> removeFile(String fileType, StorageService storageService) async {
    String? path;
    String? data;
    switch (fileType) {
      case 'matriculaURL':
        path = scholarship!.matriculaURL;
        data = scholarship!.matriculaURLName;
        break;
      case 'horarioURL':
        path = scholarship!.horarioURL;
        data = scholarship!.horarioURLName;
        break;
      case 'soporteURL':
        path = scholarship!.soporteURL;
        data = scholarship!.soporteURLName;
        break;
      case 'bankaccountURL':
        path = scholarship!.bankaccountURL;
        data = scholarship!.bankaccountName;
        break;
      default:
        throw Exception('Invalid fileType');
    }
    if (data != null && path != null) {
      await storageService.deleteFileFromST(path: path, data: data);
      var updatedData = await getScholarshipData();
      updatedData.remove(fileType);
      updatedData.remove('${fileType}Name');
      await dbService.addEntryToDBWithName(path: 'scholarships', entry: updatedData, name: uid);
    }
  }

  bool getBankDetailAURLFile() {
    try {
      return scholarship!.getBankDetailAURLFile();
    } catch (e) {
      return false;
    }
  }

  void setBankDetailAURLFile(bool isFile) {
    scholarship?.setBankDetailAURLFile(isFile);
  }

  String? getBankaccount() {
    return scholarship?.bankaccount;
  }

  Future<bool> setBankaccount(String? bankaccount) async {
    try {
      var data = await getScholarshipData();
      data['bankaccount'] = bankaccount;
      await dbService.addEntryToDBWithName(path: 'scholarships', entry: data, name: uid);
      return true;
    } catch (e) {
      return false;
    }
  }

  num getStatusNum() {
    try {
      return scholarship!.getStatusNum();
    } catch (e) {
      return 0;
    }
  }
}
