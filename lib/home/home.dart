// File: home.dart (EXE)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// Import necessary services and widgets
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/scholarship_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:fcccontrolcenter/services/db_user_service.dart';
import 'package:fcccontrolcenter/services/user_service.dart'; // Import UserService
import 'home_table.dart';
import 'create_user_button.dart';
import 'scholarship_popup.dart';
import 'ayudas_popup.dart'; // Import AyudasPopup

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

  // Fetch all users from the database
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
                const CreateUserButton(), // Button for creating new users
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _updateUsers, // Save changes
                  style: ElevatedButton.styleFrom(),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Add some spacing
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AyudasPopup(
                          dbService: widget.dbs,
                          storageService: widget.st,
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(),
                  child: const Text(
                    'Ayudas',
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
                await AuthService.signOut(); // Sign out functionality
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
          ],
        ),
      ),
    );
  }

  // Update a single user if changes are detected
  void _updateUser(int index) async {
    if (users![index] != originalUsers![index]) {
      await DBUserService.updateUser(
          widget.dbs, users![index]['uid'], users![index]);
    }
    setState(() {
      originalUsers = List.from(users!);
    });
  }

  // Update all users that have changes
  Future<void> _updateUsers() async {
    for (int i = 0; i < users!.length; i++) {
      if (users![i] != originalUsers![i]) {
        await DBUserService.updateUser(widget.dbs, users![i]['uid'], users![i]);
      }
    }
    await _fetchUsers(); // Refresh the user list
  }

  // Confirm before deleting a user
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
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('No', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
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

  // Show scholarship information for a user
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
          name: user['displayName'],
          scholarshipData: scholarshipData!,
          removeFile: (fileType) async {
            await scholarshipService.removeFile(fileType, widget.st);
            await _fetchUsers(); // Refresh the user list
          },
          downloadFile: (fileType) async {
            final fileDataUrl = await scholarshipService.getURLFileURL(
              fileType: UrlFileType.values.firstWhere(
                  (e) => e.toString().split('.').last == fileType),
              storageService: widget.st,
            );

            final fileDataName = await scholarshipService.getURLFileData(
              fileType: UrlFileType.values.firstWhere(
                  (e) => e.toString().split('.').last == fileType),
              storageService: widget.st,
            );

            if (kDebugMode) {
              print(fileDataUrl);
            }

            if (fileDataUrl != null && fileDataName != null) {
              final downloadDir = await getDownloadsDirectory();
              final extensionType = fileDataName.contains('.pdf')
                  ? '.pdf'
                  : fileDataUrl.contains('.png')
                      ? '.png'
                      : fileDataUrl.contains('.jpeg')
                          ? '.jpeg'
                          : fileDataUrl.contains('.jpg')
                              ? '.jpg'
                              : '';
              //name based on URL File Type where matriculaURL is matricula, horarioURL is horario, soporteURL is soporte
              final name = fileType == 'matriculaURL'
                  ? 'matricula'
                  : fileType == 'horarioURL'
                      ? 'horario'
                      : fileType == 'soporteURL'
                          ? 'soporte'
                          : fileType == 'bankaccountURL'
                              ? 'bankaccount'
                              : '';
              final savePath =
                  '${downloadDir!.path}/$name${user['displayName']}$extensionType';
              final uri = Uri.parse(fileDataUrl);

              await Dio().downloadUri(uri, savePath);
            }
          },
          scholarshipService: scholarshipService,
          storageService: widget.st,
        );
      },
    );
  }
}
