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

  ScholarshipService._({this.scholarship, required this.dbService, required this.uid});

  /// Crea una nueva instancia de `ScholarshipService`.
  ///
  /// Este método es un constructor de fábrica que crea una nueva instancia de `ScholarshipService`
  /// y configura la beca llamando a `configureScholarship`.
  ///
  /// @param uid Identificador único del usuario.
  /// @param dbService Instancia de `DBService` para acceder a la base de datos.
  /// @return Una instancia configurada de `ScholarshipService`.
  static Future<ScholarshipService> create({required String uid, required DBService dbService}) async {
    try {
      var scholarshipService = ScholarshipService._(scholarship: null, dbService: dbService, uid: uid);
      await scholarshipService.configureScholarship();
      return scholarshipService;
    } catch (e) {
      throw Exception('Failed to create ScholarshipService: $e');
    }
  }

  /// Configura la beca obteniendo datos desde la base de datos.
  ///
  /// Intenta obtener los datos de la beca desde la base de datos a través de la función `_getScholarshipDataFromDB`.
  /// Si no existen datos, se inicializa un nuevo objeto `Scholarship` con valores predeterminados.
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

  /// Obtiene datos de beca desde la base de datos.
  ///
  /// @param uid Identificador único del usuario.
  /// @return Mapa con los datos de la beca o `null` si no existen datos.
  Future<Map<String, dynamic>?> _getScholarshipDataFromDB(String uid) async {
    return await dbService.getFromDB(path: 'scholarships', data: uid);
  }

  /// Retorna los datos de la beca actual.
  ///
  /// @return Mapa con los datos de la beca actual.
  getScholarshipData() {
    return scholarship?.getScholarshipData();
  }

  /// Obtiene un archivo específico desde Firebase Storage.
  ///
  /// @param fileType Tipo de archivo a obtener.
  /// @param storageService Instancia de `StorageService` para acceder al almacenamiento.
  /// @return Archivo en formato `Uint8List` o `null` si no se encuentra.
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

  /// Obtiene la URL de un archivo específico desde Firebase Storage.
  ///
  /// @param fileType Tipo de archivo cuya URL se desea obtener.
  /// @param storageService Instancia de `StorageService`.
  /// @return La URL del archivo o `null` si no existe.
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

  /// Obtiene tanto el path como los datos de un archivo específico.
  ///
  /// @param fileType Tipo de archivo.
  /// @param storageService Instancia de `StorageService`.
  /// @return Mapa con `path` y `data` del archivo.
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
        return {'path': path, 'data': data};
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching file url: $e');
    }
  }

  /// Obtiene el nombre del archivo específico desde la beca.
  ///
  /// @param fileType Tipo de archivo.
  /// @return Nombre del archivo o `null` si no existe.
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

  /// Selecciona un archivo desde el dispositivo usando el File Picker.
  ///
  /// @return Un `List` con el archivo y su nombre si se selecciona correctamente, `null` si no se selecciona nada.
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

  /// Agrega un archivo de requisito a la beca y lo guarda en el almacenamiento.
  ///
  /// @param st Instancia de `StorageService`.
  /// @param type Tipo de archivo.
  /// @param fileURL URL del archivo.
  /// @param fileName Nombre del archivo.
  /// @return `true` si se agrega correctamente, `false` en caso contrario.
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

      // Añadir el archivo al almacenamiento
      await st.addFile(path: 'scholarships/$uid/$fileType', file: fileURL, data: fileName);

      // Actualizar la base de datos con la nueva información de beca
      await dbService.addEntryToDBWithName(path: 'scholarships', entry: data, name: uid);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Elimina un archivo específico asociado a la beca.
  ///
  /// @param fileType Tipo de archivo a eliminar.
  /// @param storageService Instancia de `StorageService` para acceder al almacenamiento.
  /// Elimina tanto el archivo del almacenamiento como la referencia en la base de datos.
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
      // Eliminar el archivo del almacenamiento
      await storageService.deleteFileFromST(path: path, data: data);
      // Remover la información del archivo de la base de datos
      var updatedData = await getScholarshipData();
      updatedData.remove(fileType);
      updatedData.remove('${fileType}Name');
      await dbService.addEntryToDBWithName(path: 'scholarships', entry: updatedData, name: uid);
    }
  }

  /// Verifica si los detalles bancarios están guardados como archivo.
  ///
  /// @return `true` si los detalles están en archivo, `false` en caso contrario.
  bool getBankDetailAURLFile() {
    try {
      return scholarship!.getBankDetailAURLFile();
    } catch (e) {
      return false;
    }
  }

  /// Establece si los detalles bancarios deben ser tratados como archivo.
  ///
  /// @param isFile Booleano que indica si los detalles bancarios están en archivo.
  void setBankDetailAURLFile(bool isFile) {
    scholarship?.setBankDetailAURLFile(isFile);
  }

  /// Obtiene el número de cuenta bancaria asociado con la beca.
  ///
  /// @return El número de cuenta bancaria o `null` si no existe.
  String? getBankaccount() {
    return scholarship?.bankaccount;
  }

  /// Establece o actualiza el número de cuenta bancaria asociado a la beca.
  ///
  /// @param bankaccount Número de cuenta bancaria.
  /// @return `true` si se actualiza correctamente, `false` en caso contrario.
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

  /// Obtiene el número de requisitos cumplidos para esta beca.
  ///
  /// @return Un valor numérico indicando cuántos de los documentos requeridos están disponibles.
  num getStatusNum() {
    try {
      return scholarship!.getStatusNum();
    } catch (e) {
      return 0;
    }
  }
}
