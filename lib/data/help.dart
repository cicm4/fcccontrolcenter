class HelpVar {
  String? email;
  String? helpType;
  String? id;
  String? message;
  String? time;
  String? uid;
  String? status;

  HelpVar({
    this.email,
    this.helpType,
    this.id,
    this.message,
    this.time,
    this.uid,
    this.status,
  });

  /// Create a `HelpVar` instance from a map of data.
  ///
  /// This factory constructor takes a `Map<String, dynamic>` as an argument,
  /// representing the help data. It extracts the data from the map and uses it
  /// to create a new `HelpVar` object.
  factory HelpVar.fromMap(Map<String, dynamic> data) {
    return HelpVar(
      email: data['email'],
      helpType: data['help'],
      id: data['id'],
      message: data['message'],
      time: data['time'],
      uid: data['uid'],
      status: data['status'],
    );
  }

  get help => null;

  /// Converts the `HelpVar` object to a JSON-serializable map.
  ///
  /// This method collects the data of the `HelpVar` object and returns it as a
  /// `Map<String, dynamic>`. The keys in the returned map correspond to the
  /// properties of the `HelpVar` class.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'help': helpType,
      'id': id,
      'message': message,
      'time': time,
      'uid': uid,
      'status': status,
    };
  }
}
