enum Help { deportivo, academico, salud, otro }

/// `HelpExtension` proporciona una forma conveniente de obtener un nombre
/// legible para cada valor del enum `Help`.
///
/// Esta extensión añade un método `displayName` al enum `Help` que devuelve 
/// una cadena de texto con el nombre adecuado para cada tipo de ayuda.
extension HelpExtension on Help {
  String get displayName {
    switch (this) {
      case Help.deportivo:
        return 'Deportivo';
      case Help.academico:
        return 'Académico';
      case Help.salud:
        return 'Salud';
      case Help.otro:
        return 'Otro';
      default:
        return '';
    }
  }
}

/// `HelpVar` representa una solicitud de ayuda realizada por un usuario.
///
/// Esta clase contiene información sobre una solicitud de ayuda, incluyendo
/// el tipo de ayuda (`Help`), un mensaje de solicitud, la fecha y otros detalles.
class HelpVar {
  String? email; // Correo electrónico del usuario que solicita la ayuda
  Help? helpType; // Tipo de ayuda solicitada (deportivo, académico, salud, otro)
  String? id; // Identificador único de la solicitud
  String? message; // Mensaje detallado del usuario sobre la solicitud de ayuda
  String? time; // Fecha de la solicitud
  String? uid; // UID del usuario solicitante
  String? status; // Estado de la solicitud (ej. pendiente, aceptada, rechazada)
  String? file; // Nombre del archivo adjunto, si hay alguno

  HelpVar({
    this.email,
    this.helpType,
    this.id,
    this.message,
    this.time,
    this.uid,
    this.status,
    this.file,
  });

  /// Crea una instancia de `HelpVar` a partir de un mapa de datos.
  ///
  /// Convierte un mapa de datos obtenido de la base de datos a un objeto `HelpVar`.
  factory HelpVar.fromMap(Map<String, dynamic> data) {
    return HelpVar(
      email: data['email'],
      helpType: Help.values.firstWhere(
          (e) => e.toString().split('.').last == data['help'],
          orElse: () => Help.otro), // Convierte la cadena al valor del enum `Help`
      id: data['id'],
      message: data['message'],
      time: data['time'],
      uid: data['uid'],
      status: data['status'],
      file: data['file'],
    );
  }

  /// Convierte el objeto `HelpVar` en un mapa que puede ser serializado a JSON.
  ///
  /// Utilizado para guardar la información de `HelpVar` en la base de datos.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'help': helpType?.toString().split('.').last, // Convierte el valor del enum a cadena
      'id': id,
      'message': message,
      'time': time,
      'uid': uid,
      'status': status,
      'file': file,
    };
  }
}
