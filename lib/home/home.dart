import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/scholarship_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:fcccontrolcenter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:fcccontrolcenter/services/db_user_service.dart';
import 'home_table.dart';
import 'create_user_button.dart';
import 'scholarship_popup.dart';

class Home extends StatefulWidget {
  final DBService dbs;
  final StorageService st;

  const Home({super.key, required this.dbs, required this.st});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>>? users;
  List<Map<String, dynamic>>? originalUsers;
  final int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final fetchedUsers = await DBUserService.getAllUsers(widget.dbs);
    setState(() {
      users = fetchedUsers;
      originalUsers = List.from(fetchedUsers!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (users == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (users!.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No users found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0b512d),
        title: const Text(
          "Vista de administrador",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0b512d),
              Color(0xFFe6e6e3),
              Color(0xFF22c0c6),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CreateUserButton(),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _updateUsers,
                  style: ElevatedButton.styleFrom(),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: HomeTable(
                  users: users!,
                  originalUsers: originalUsers!,
                  dbs: widget.dbs,
                  updateUser: _updateUser,
                  deleteUser: _deleteUser,
                  showScholarshipInfo: _showScholarshipInfo,
                  rowsPerPage: _rowsPerPage,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                await AuthService.signOut();
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0b512d),
                ),
              ),
            ),
            const SizedBox(height: 20),
            //Text("UserID: ${UserService().user?.uid}", style: const TextStyle(fontSize: 20, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  void _updateUser(int index) async {
    if (users![index] != originalUsers![index]) {
      await DBUserService.updateUser(
          widget.dbs, users![index]['uid'], users![index]);
    }
    setState(() {
      originalUsers = List.from(users!);
    });
  }

  Future<void> _updateUsers() async {
    for (int i = 0; i < users!.length; i++) {
      if (users![i] != originalUsers![i]) {
        await DBUserService.updateUser(widget.dbs, users![i]['uid'], users![i]);
      }
    }
    await _fetchUsers(); // Refresh the user list
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: const Text(
              'Seguro que deseas eliminar este usuario, esta accion es permanente'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  users!.removeAt(index);
                  originalUsers!.removeAt(index);
                });
              },
              child: const Text('Seguro', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showScholarshipInfo(int index) async {
    final user = users![index];
    final scholarshipService = await ScholarshipService.create(
      uid: user['uid'],
      dbService: widget.dbs,
    );
    final scholarshipData = scholarshipService.getScholarshipData();

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScholarshipPopup(
          scholarshipData: scholarshipData!,
          removeFile: (fileType) async {
            await scholarshipService.removeFile(fileType, widget.st);
            await _fetchUsers(); // Refresh the user list
          },
          downloadFile: (fileType) async {
            final fileData = await scholarshipService.getURLFile(
              fileType: UrlFileType.values.firstWhere((e) => e.toString().split('.').last == fileType),
              storageService: widget.st,
            );
            
            // Handle file download logic here
          },
          scholarshipService: scholarshipService,
          storageService: widget.st,
        );
      },
    );
  }
}
