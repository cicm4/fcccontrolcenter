import 'package:fcccontrolcenter/firebase_options.dart';
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:fcccontrolcenter/shared/shared/routes.dart';
import 'package:fcccontrolcenter/shared/shared/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/database_service.dart';
import 'services/user_service.dart';
import 'services/storage_service.dart';

import 'wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
    runApp(const MyApp());
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize Firebase: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    DBService dbs = DBService();
    AuthService auth = AuthService(dbs);
    UserService us = UserService();
    StorageService st = StorageService();

    return StreamProvider<User?>.value(
      value: us.userStream,
      initialData: us.user,
      child: MaterialApp(
        routes: getAppRoutes(auth, dbs, st),
        theme: generalTheme,
        home: Wrapper(auth: auth, dbs: dbs, st: st),
      ),
    );
  }
}
