import 'package:fcccontrolcenter/home/user_data_table_source.dart';
import 'package:flutter/material.dart';

class HomeTable extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> originalUsers;
  final dynamic dbs;
  final Function(int) updateUser;
  final Function(int) deleteUser;
  final Function(int) showScholarshipInfo;  // Add this line
  final int rowsPerPage;

  const HomeTable({
    required this.users,
    required this.originalUsers,
    required this.dbs,
    required this.updateUser,
    required this.deleteUser,
    required this.showScholarshipInfo,  // Add this line
    required this.rowsPerPage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child:
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
                source: UserDataTableSource(users, updateUser, deleteUser, showScholarshipInfo),  // Update this line
                columnSpacing: constraints.maxWidth * 0.02,
              ),
          ),
        );
      },
    );
  }
}
