// Required imports for main.dart
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Add this line

import 'services/database_service.dart';
import 'services/user_service.dart';
import 'wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    DBService dbs = DBService();
    AuthService auth = AuthService(dbs);
    UserService us = UserService();

    return StreamProvider<User?>.value(
      value: us.userStream,
      initialData: us.user,
      child: MaterialApp(
        home: Wrapper(auth: auth, dbs: dbs),
      ),
    );
  }
}
