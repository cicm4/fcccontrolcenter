import 'package:flutter/material.dart';
import 'user_data_table_source.dart';

class HomeTable extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> originalUsers;
  final dynamic dbs;
  final Function(int) updateUser;
  final Function(int) deleteUser;
  final int rowsPerPage;

  const HomeTable({
    required this.users,
    required this.originalUsers,
    required this.dbs,
    required this.updateUser,
    required this.deleteUser,
    required this.rowsPerPage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PaginatedDataTable(
                rowsPerPage: rowsPerPage,
                columns: const [
                  DataColumn(label: Text('Nombre de usuario')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Cedula')),
                  DataColumn(label: Text('Telefono')),
                  DataColumn(label: Text('Ubicación')),
                  DataColumn(label: Text('Deporte')),
                  DataColumn(label: Text('Ayudas')),
                  DataColumn(label: Text('Beca')),
                  DataColumn(label: Text('')),
                ],
                source: UserDataTableSource(users, updateUser, deleteUser),
                columnSpacing: constraints.maxWidth * 0.02,
              ),
            ],
          ),
        );
      },
    );
  }
}