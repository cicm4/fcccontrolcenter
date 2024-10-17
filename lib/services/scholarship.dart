/// La clase `Scholarship` representa una beca.
///
/// Esta clase es utilizada por `ScholarshipService` para gestionar los datos de una beca de un usuario.
/// No debe ser utilizada directamente fuera de `ScholarshipService`.
///
/// Contiene propiedades como el ID único de la beca (`uid`), el GID (`gid`), las URLs y nombres de documentos de matrícula, horario, y soporte, así como los datos bancarios asociados a la beca.
class Scholarship {
  final String? uid; // ID único de la beca.
  final String? gid; // GID de la beca.
  final String? matriculaURL; // URL del documento de matrícula.
  final String? matriculaURLName; // Nombre del documento de matrícula.
  final String? horarioURL; // URL del documento de horario.
  final String? horarioURLName; // Nombre del documento de horario.
  final String? soporteURL; // URL del documento de soporte de pago.
  final String? soporteURLName; // Nombre del documento de soporte de pago.
  final String? bankaccount; // Número de cuenta bancaria asociado a la beca.
  final String? bankaccountURL; // URL del documento de cuenta bancaria.
  final String? bankaccountName; // Nombre asociado a la cuenta bancaria.
  bool? isBankDataFile; // Indica si los datos bancarios están en un archivo.

  /// Constructor que crea una nueva `Scholarship` con los datos proporcionados.
  Scholarship({
    required this.uid,
    required this.gid,
    required this.matriculaURL,
    required this.horarioURL,
    required this.soporteURL,
    required this.bankaccount,
    required this.matriculaURLName,
    required this.horarioURLName,
    required this.soporteURLName,
    required this.bankaccountName,
    required this.bankaccountURL,
    this.isBankDataFile,
  }) {
    isBankDataFile ??= false;
  }

  /// Método para crear un objeto `Scholarship` a partir de un `Map<String, dynamic>`.
  ///
  /// Utiliza un mapa de datos para inicializar las propiedades de `Scholarship`.
  factory Scholarship.fromMap(Map<String, dynamic> data) {
    return Scholarship(
      uid: data['uid'],
      gid: data['gid'],
      matriculaURL: data['matriculaURL'],
      horarioURL: data['horarioURL'],
      soporteURL: data['soporteURL'],
      bankaccountURL: data['bankaccountURL'],
      bankaccount: data['bankaccount'],
      matriculaURLName: data['matriculaURLName'],
      horarioURLName: data['horarioURLName'],
      soporteURLName: data['soporteURLName'],
      bankaccountName: data['bankaccountName'],
      isBankDataFile: data['isBankDataFile'],
    );
  }

  /// Obtiene el número de estatus de la beca, basado en cuántos documentos están disponibles.
  ///
  /// Retorna un valor que indica cuántos de los documentos requeridos están presentes.
  num getStatusNum() {
    int status = 0;
    if (matriculaURL != null) status++;
    if (horarioURL != null) status++;
    if (soporteURL != null) status++;
    if (bankaccountURL != null || bankaccount != null) status++;
    return status;
  }

  /// Convierte los datos de la beca a un `Map<String, dynamic>` para ser utilizado en Firebase.
  Map<String, dynamic> getScholarshipData() {
    return {
      'uid': uid,
      'gid': gid,
      'matriculaURL': matriculaURL,
      'horarioURL': horarioURL,
      'soporteURL': soporteURL,
      'bankaccountURL': bankaccountURL,
      'bankaccount': bankaccount,
      'matriculaURLName': matriculaURLName,
      'horarioURLName': horarioURLName,
      'soporteURLName': soporteURLName,
      'bankAccountName': bankaccountName,
      'isBankDataFile': isBankDataFile,
    };
  }

  /// Métodos para obtener y configurar si el detalle bancario está almacenado como un archivo.
  getBankDetailAURLFile() {
    return isBankDataFile;
  }

  setBankDetailAURLFile(bool isFile) {
    isBankDataFile = isFile;
  }
}
