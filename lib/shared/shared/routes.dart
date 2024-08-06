import 'package:fcccontrolcenter/home/home.dart';
import 'package:fcccontrolcenter/login.dart';
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:flutter/widgets.dart';


Map<String, WidgetBuilder> getAppRoutes(
    AuthService auth, DBService dbs, StorageService st) {
  return {
    '/home': (context) => Home(dbs: dbs, st: st, auth: auth,),
    '/login': (context) => Login(auth: auth)
  };
}
