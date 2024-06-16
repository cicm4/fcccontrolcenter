// Required imports for wrapper.dart
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/database_service.dart';
import 'services/storage_service.dart';
import 'home.dart';
import 'login.dart';

class Wrapper extends StatelessWidget {
  final AuthService auth;
  final DBService dbs;
  final StorageService st;
  const Wrapper({super.key, required this.auth, required this.dbs, required this.st});

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<User?>(context);

    if (user == null) {
      return Login(auth: auth);
    } else {
      return Home(dbs: dbs, st: st);
    }
  }
}
