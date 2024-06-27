import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:fcccontrolcenter/services/db_user_service.dart';
import 'package:flutter/material.dart';

import 'services/database_service.dart';
import 'services/storage_service.dart';

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
  final int _rowsPerPage = 15;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        Future.delayed(const Duration(milliseconds: 500)),
        DBUserService.getAllUsers(widget.dbs),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('An error occurred: ${snapshot.error}'),
            ),
          );
        }

        if (users == null) {
          users = snapshot.data?[1] as List<Map<String, dynamic>>?;
          originalUsers = List.from(users!);
        }

        if (users == null || users!.isEmpty) {
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              PaginatedDataTable(
                                rowsPerPage: _rowsPerPage,

                                columns: const [
                                  DataColumn(label: Text('Nombre de usuario')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Cedula')),
                                  DataColumn(label: Text('Telefono')),
                                  DataColumn(label: Text('Ubicación')),
                                  DataColumn(label: Text('Deporte')),
                                  DataColumn(label: Text('Ayudas')),
                                  DataColumn(label: Text('Beca')),
                                  DataColumn(label: Text('Acciones')),
                                ],
                                source: UserDataTableSource(users!, _updateUser, _deleteUser),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _updateUsers,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0b512d),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Actualizar Usuarios',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateUser(int index) async {
    if (users![index] != originalUsers![index]) {
      await DBUserService.updateUser(widget.dbs, users![index]['uid'], users![index]);
    }
    setState(() {
      originalUsers = List.from(users!);
    });
  }

  void _deleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: const Text('Seguro que deseas eliminar este usuario, esta accion es permanente'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                // Perform delete operation
                // await DBUserService.deleteUser(widget.dbs, users![index]['uid']);
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

  void _updateUsers() async {
    for (int i = 0; i < users!.length; i++) {
      if (users![i] != originalUsers![i]) {
        await DBUserService.updateUser(widget.dbs, users![i]['uid'], users![i]);
      }
    }
    setState(() {
      originalUsers = List.from(users!);
    });
  }
}

class UserDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> users;
  final Function(int) updateUser;
  final Function(int) deleteUser;

  UserDataTableSource(this.users, this.updateUser, this.deleteUser);

  @override
  DataRow getRow(int index) {
    final user = users[index];
    return DataRow(cells: [
      DataCell(TextFormField(
        initialValue: user['displayName'] ?? '',
        onChanged: (value) {
          user['displayName'] = value;
        },
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      )),
      DataCell(TextFormField(
        initialValue: user['email'] ?? '',
        onChanged: (value) {
          user['email'] = value;
        },
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      )),
      DataCell(TextFormField(
        initialValue: user['gid'] ?? '',
        onChanged: (value) {
          user['gid'] = value;
        },
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      )),
      DataCell(TextFormField(
        initialValue: user['phone'] ?? '',
        onChanged: (value) {
          user['phone'] = value;
        },
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      )),
      DataCell(TextFormField(
        initialValue: user['location'] ?? '',
        onChanged: (value) {
          user['location'] = value;
        },
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      )),
      DataCell(TextFormField(
        initialValue: user['sport'] ?? '',
        onChanged: (value) {
          user['sport'] = value;
        },
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      )),
      DataCell(ElevatedButton(
        onPressed: () {
          // Handle Ayudas button logic here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0b512d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Ayudas',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      )),
      DataCell(ElevatedButton(
        onPressed: () {
          // Handle Beca button logic here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0b512d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Beca',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      )),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              deleteUser(index);
            },
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
