enum Help { deportivo, academico, salud, otro }

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

class HelpVar {
  String? email;
  Help? helpType; // Use Help enum
  String? id;
  String? message;
  String? time;
  String? uid;
  String? status;
  String? file;

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

  /// Create a `HelpVar` instance from a map of data.
  factory HelpVar.fromMap(Map<String, dynamic> data) {
    return HelpVar(
      email: data['email'],
      helpType: Help.values.firstWhere(
          (e) => e.toString().split('.').last == data['help'],
          orElse: () => Help.otro), // Convert string to enum
      id: data['id'],
      message: data['message'],
      time: data['time'],
      uid: data['uid'],
      status: data['status'],
      file: data['file'],
    );
  }

  /// Converts the `HelpVar` object to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'help': helpType?.toString().split('.').last, // Convert enum to string
      'id': id,
      'message': message,
      'time': time,
      'uid': uid,
      'status': status,
      'file': file,
    };
  }
}
