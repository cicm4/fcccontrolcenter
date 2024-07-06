/// The `Scholarship` class represents a scholarship.
///
/// This class is used by the `ScholarshipService` class to manage the scholarship data for a user.
/// It should not be used directly outside of the `ScholarshipService` class.
///
/// The class has properties for the unique ID of the scholarship (`uid`), the GID of the scholarship (`gid`),
/// the URLs and names of the matricula, horario, and soporte documents, and the bank account associated with the scholarship.
///
/// The class provides a constructor for creating a new `Scholarship` with the given data, a factory constructor for creating a new `Scholarship` from a map of data,
/// a method for getting the status number of the scholarship (`getStatusNum`), and a method for getting a map of the scholarship data (`getScholarshipData`).
///
/// Example usage (within the `ScholarshipService` class):
///
/// ```dart
/// final Scholarship scholarship = Scholarship.fromMap(scholarshipData);
/// final num statusNum = scholarship.getStatusNum();
/// final Map<String, dynamic> scholarshipData = scholarship.getScholarshipData();
/// ```
class Scholarship {
  /// The unique ID of the scholarship.
  ///
  /// This is a unique identifier for the scholarship. It is used to distinguish this scholarship from others in the database.
  final String? uid;

  /// The GID of the scholarship.
  ///
  /// This is another unique identifier for the scholarship. It is used in conjunction with `uid` to uniquely identify the scholarship.
  final String? gid;

  /// The URL of the matricula.
  ///
  /// This is the URL where the matricula document for the scholarship can be found. It is stored in Firebase Storage and can be used to download the document.
  final String? matriculaURL;

  /// The Name of the matricula.
  ///
  /// This is the name of the matricula document. It is used for display purposes.
  final String? matriculaURLName;

  /// The URL of the horario.
  ///
  /// This is the URL where the horario document for the scholarship can be found. It is stored in Firebase Storage and can be used to download the document.
  final String? horarioURL;

  /// The Name of the horario.
  ///
  /// This is the name of the horario document. It is used for display purposes.
  final String? horarioURLName;

  /// The URL of the soporte.
  ///
  /// This is the URL where the soporte document for the scholarship can be found. It is stored in Firebase Storage and can be used to download the document.
  final String? soporteURL;

  /// The Name of the soporte.
  ///
  /// This is the name of the soporte document. It is used for display purposes.
  final String? soporteURLName;

  /// The bank account associated with the scholarship.
  ///
  /// This is the bank account number where the scholarship funds should be deposited. It is used for payment purposes.
  final String? bankaccount;

  /// The URL of the bank account.
  ///
  /// This is the URL where the bank account document for the scholarship can be found. It is stored in Firebase Storage and can be used to download the document.
  final String? bankaccountURL;

  /// The Name of the bank account.
  ///
  /// This is the name associated with the bank account. It is used for display purposes.
  final String? bankaccountName;

  /// Is the bank data a file such as a PDF/PNG/JPG..?
  ///
  /// This is a boolean that represents that
  bool? isBankDataFile;

  /// Creates a new `Scholarship` with the given data.
  ///
  /// This constructor takes several arguments, each representing a different piece of scholarship data.
  /// All arguments are required and must not be `null`.
  ///
  /// The `uid` and `gid` arguments represent the unique ID and GID of the scholarship, respectively.
  /// The `matriculaURL`, `horarioURL`, and `soporteURL` arguments represent the URLs of the matricula, horario, and soporte documents, respectively.
  /// The `bankaccount` argument represents the bank account associated with the scholarship.
  /// The `matriculaURLName`, `horarioURLName`, `soporteURLName`, and `bankaccountName` arguments represent the names of the matricula, horario, soporte documents, and bank account, respectively.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final Scholarship scholarship = Scholarship(
  ///   uid: '123',
  ///   gid: '456',
  ///   matriculaURL: 'https://example.com/matricula',
  ///   horarioURL: 'https://example.com/horario',
  ///   soporteURL: 'https://example.com/soporte',
  ///   bankaccount: '1234567890',
  ///   matriculaURLName: 'Matricula',
  ///   horarioURLName: 'Horario',
  ///   soporteURLName: 'Soporte',
  ///   bankaccountName: 'Bank Account',
  /// );
  /// ```
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

  /// Creates a new `Scholarship` from a map of data.
  ///
  /// This factory constructor takes a `Map<String, dynamic>` as an argument, which represents the scholarship data.
  /// It extracts the data from the map and uses it to create a new `Scholarship` object.
  ///
  /// The keys in the map should correspond to the properties of the `Scholarship` class.
  /// If a key is missing from the map or the value associated with a key is `null`, the corresponding property in the created `Scholarship` object will be `null`.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final Map<String, dynamic> scholarshipData = {
  ///   'uid': '123',
  ///   'gid': '456',
  ///   // ...
  /// };
  /// final Scholarship scholarship = Scholarship.fromMap(scholarshipData);
  /// ```
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

  /// Returns the status number of the scholarship.
  ///
  /// This method calculates and returns the status number of the scholarship, which is a count of the number of non-null document URLs and bank account.
  ///
  /// The method checks each of the `matriculaURL`, `horarioURL`, `soporteURL`, and `bankaccount` properties in turn.
  /// If a property is not `null`, the status number is incremented by 1.
  ///
  /// The method returns the status number as a `num`.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final Scholarship scholarship = Scholarship(
  ///   uid: '123',
  ///   gid: '456',
  ///   matriculaURL: 'https://example.com/matricula',
  ///   horarioURL: 'https://example.com/horario',
  ///   soporteURL: 'https://example.com/soporte',
  ///   bankaccount: '1234567890',
  ///   matriculaURLName: 'Matricula',
  ///   horarioURLName: 'Horario',
  ///   soporteURLName: 'Soporte',
  ///   bankaccountName: 'Bank Account',
  /// );
  /// final num statusNum = scholarship.getStatusNum();
  /// ```
  num getStatusNum() {
    int status = 0;
    if (matriculaURL != null) {
      status++;
    }
    if (horarioURL != null) {
      status++;
    }
    if (soporteURL != null) {
      status++;
    }
    if (bankaccountURL != null || bankaccount != null) {
      status++;
    }
    return status;
  }

  /// Returns a map of the scholarship data.
  ///
  /// This method collects the data of the `Scholarship` object and returns it as a `Map<String, dynamic>`.
  ///
  /// The keys in the returned map correspond to the properties of the `Scholarship` class.
  /// The values associated with each key are the values of the corresponding properties in the `Scholarship` object.
  ///
  /// If a property in the `Scholarship` object is `null`, the value associated with the corresponding key in the returned map will also be `null`.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// final Scholarship scholarship = Scholarship(
  ///   uid: '123',
  ///   gid: '456',
  ///   matriculaURL: 'https://example.com/matricula',
  ///   horarioURL: 'https://example.com/horario',
  ///   soporteURL: 'https://example.com/soporte',
  ///   bankaccount: '1234567890',
  ///   matriculaURLName: 'Matricula',
  ///   horarioURLName: 'Horario',
  ///   soporteURLName: 'Soporte',
  ///   bankaccountName: 'Bank Account',
  /// );
  /// final Map<String, dynamic> scholarshipData = scholarship.getScholarshipData();
  /// ```
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

  getBankDetailAURLFile() {
    return isBankDataFile;
  }

  setBankDetailAURLFile(bool isFile) {
    isBankDataFile = isFile;
  }
}
