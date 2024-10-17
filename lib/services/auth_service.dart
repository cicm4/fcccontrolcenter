// Importaciones necesarias para Firebase, Firestore y los servicios de la aplicación.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcccontrolcenter/services/admin_service.dart';
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// `AuthService`: Servicio que maneja la autenticación de usuarios a través de Firebase Authentication.
/// Se encarga de los inicios de sesión, registros y gestión de usuarios en la base de datos de Firestore.
class AuthService {
  /// Constructor que pasa un servicio de base de datos para evitar múltiples instancias del servicio de base de datos.
  AuthService(this.dbs);

  // Servicio de base de datos utilizado para agregar nuevos usuarios a Firestore.
  DBService dbs;

  // Instancia de FirebaseAuth para manejar el flujo de autenticación.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Iniciar sesión con correo electrónico y contraseña.
  ///
  /// Este método intenta iniciar sesión usando el correo y la contraseña del usuario.
  /// Si el usuario no existe en la base de datos, lo añade.
  ///
  /// @param emailAddress Dirección de correo del usuario.
  /// @param password Contraseña del usuario.
  ///
  /// @return Un `Future` que se completa con un booleano si el inicio de sesión fue exitoso, o con un código de error si ocurre un error.
  Future<dynamic> signInEmailAndPass(
      {required emailAddress, required password}) async {
    try {
      // Intenta iniciar sesión con el correo y la contraseña proporcionados.
      await _firebaseAuth.signInWithEmailAndPassword(
          email: emailAddress, password: password);
      // Verifica si el usuario está en la base de datos.
      UserService us = UserService();

      bool isUserInDB = await _isUserInDB(uid: us.user!.uid);
      // Si el usuario no está en la base de datos, se intenta agregarlo.

      bool isUserAdmin = await AdminService.isAdmin(userService: us, dbService: dbs);

      // Si el usuario no es administrador, lanza una excepción.
      if (!isUserAdmin) {
        throw FirebaseAuthException(
            code: 'user-not-found', message: 'Usuario no encontrado');
      }

      // Si el usuario no está en la base de datos, cierra sesión y lanza una excepción.
      if (!isUserInDB) {
        AuthService.signOut();
        throw FirebaseAuthException(
            code: 'user-not-found', message: 'Usuario no encontrado');
      }

      // Si el inicio de sesión fue exitoso, devuelve `true`.
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
    } catch (e) {
      _handleGeneralException(e);
    }
  }

  /// Maneja excepciones generales, devolviendo un mensaje amigable al usuario.
  static String _handleGeneralException(e) {
    if (kDebugMode) {
      print(e);
    }
    return 'Ocurrió un error inesperado. Por favor, intente de nuevo.';
  }

  /// Maneja excepciones de FirebaseAuth proporcionando mensajes de error amigables al usuario.
  ///
  /// @param e La excepción de FirebaseAuth encontrada durante el inicio de sesión o registro.
  /// @return Un mensaje de error amigable al usuario basado en el código de la excepción.
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    if (kDebugMode) {
      print(e); // Solo imprime los errores en modo depuración.
    }
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return 'Correo electrónico o contraseña incorrectos.';
      case 'weak-password':
        return 'La contraseña proporcionada es demasiado débil.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta para ese correo electrónico.';
      case 'invalid-email':
        return 'La dirección de correo electrónico no es válida.';
      default:
        return 'Ocurrió un error inesperado. Por favor, intente de nuevo.';
    }
  }

  /// Cierra la sesión del usuario actual.
  ///
  /// Este método cierra la sesión del usuario actual de Firebase.
  static signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _handleGeneralException(e);
    }
  }

  /// Agrega un nuevo usuario a la base de datos.
  ///
  /// Este método crea un nuevo documento de usuario y un documento de calendario en la base de datos.
  /// También agrega una entrada a la colección `scholarships` para el nuevo usuario.
  ///
  /// El documento del usuario contiene los siguientes campos:
  /// * 'uid': ID único del usuario.
  /// * 'email': Dirección de correo del usuario.
  /// * 'displayName': Nombre mostrado del usuario.
  /// * 'photoUrl': URL de la foto de perfil del usuario.
  /// * 'type': Tipo de usuario (siempre 'donor').
  /// * 'phone': Número de teléfono del usuario.
  /// * 'sport': Deporte del usuario.
  /// * 'gid': GID del usuario.
  /// * 'location': Ubicación del usuario.
  /// * 'cid': ID del calendario del usuario.
  ///
  /// El documento del calendario contiene los siguientes campos:
  /// * 'uid': ID único del usuario.
  /// * 'cid': ID del calendario.
  /// * 'isReady': Un booleano que indica si el calendario está listo (siempre `false`).
  ///
  /// La entrada de 'scholarships' contiene el siguiente campo:
  /// * 'uid': ID único del usuario.
  ///
  /// Los parámetros [name], [phone], [sport], [gid], y [location] son opcionales y pueden ser nulos.
  ///
  /// Lanza una excepción si ocurre un error al agregar los documentos a la base de datos.
  Future<void> _addScholarship(String uid, String? gid, DBService dbService) async {
    var scholarship = {
      'uid': uid,
      'gid': gid,
    };
    await dbService.addEntryToDBWithName(
        path: 'scholarships', entry: scholarship, name: uid);
  }

  /// Verifica si un usuario está en la base de datos.
  ///
  /// Este método privado verifica si un usuario con un UID específico está en la base de datos.
  ///
  /// @param uid El UID del usuario a verificar.
  ///
  /// @return Un `Future` que se completa con un booleano. Devuelve `true` si el usuario está en la base de datos, `false` de lo contrario.
  Future<bool> _isUserInDB({String? uid}) async {
    if (uid == null) {
      return false;
    }
    try {
      return dbs.isDataInDB(data: uid, path: 'users');
    } catch (e) {
      if (kDebugMode) {
        print(e);
        return false;
      }
    }
    return false;
  }

  /// Enviar un correo de restablecimiento de contraseña.
  ///
  /// Envía un correo electrónico al usuario para restablecer su contraseña.
  ///
  /// @param email Dirección de correo del usuario.
  ///
  /// @return Un `Future` que se completa con un booleano indicando si se envió correctamente.
  Future<bool> sendResetPasswordEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Registrar un nuevo usuario con correo y contraseña.
  ///
  /// Este método intenta registrar un nuevo usuario con su correo y contraseña.
  /// Si el usuario ya existe en la base de datos, devuelve un mensaje de error.
  ///
  /// @param emailAddress Dirección de correo del nuevo usuario.
  /// @param password Contraseña del nuevo usuario.
  /// @param name Nombre del nuevo usuario.
  ///
  /// @return Un `Future` que se completa con un string. Devuelve 'Success' si el registro fue exitoso, un mensaje de error de lo contrario.
  Future<String> registerWithEmailAndPass(
      {required emailAddress,
      required password,
      required name,
      required phone,
      required sport,
      required gid,
      required location,
      required startDate}) async {
    // Registra con correo y contraseña
    FirebaseApp app = await Firebase.initializeApp(
        name: 'FCCApp', options: Firebase.app().options);
    try {
      // Intenta registrar al usuario con las credenciales proporcionadas.
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
        .createUserWithEmailAndPassword(email: emailAddress, password: password);

      // Añade al nuevo usuario a la base de datos.
      String? uid = FirebaseAuth.instanceFor(app: app).currentUser!.uid;
      String? email = FirebaseAuth.instanceFor(app: app).currentUser?.email;
      String? photoUrl = FirebaseAuth.instanceFor(app: app).currentUser?.photoURL;
      String? type = 'donor';
      photoUrl ??= '';

      var newUser = {
        'uid': uid,
        'email': email,
        'displayName': name,
        'photoUrl': photoUrl,
        'type': type,
        'phone': phone,
        'sport': sport,
        'gid': gid,
        'location': location,
        'startDate': startDate,
        'endDate': null
      };

      DBService dbs2 = DBService.withDB(FirebaseFirestore.instanceFor(app: app));

      await dbs2.addEntryToDBWithName(path: 'users', entry: newUser, name: uid);

      await _addScholarship(uid, gid, dbs2);

      await app.delete();

      // Si el registro fue exitoso, devuelve 'Success'.
      return 'Success';
    } on FirebaseAuthException catch (e) {
      await app.delete();
      // Maneja excepciones de FirebaseAuth.
      return _handleFirebaseAuthException(e);
    } catch (e) {
      await app.delete();
      // Maneja cualquier otra excepción.
      return _handleGeneralException(e);
    }
  }
}
