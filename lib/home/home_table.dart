import 'package:fcccontrolcenter/home/user_data_table_source.dart';
import 'package:flutter/material.dart';

/// `HomeTable`: Widget que representa una tabla paginada de usuarios.
///
/// Este widget muestra una tabla paginada de usuarios con varias columnas, incluyendo nombre de usuario, email, y otros datos relevantes.
/// Permite realizar acciones como actualizar y eliminar usuarios, además de mostrar información sobre becas.
class HomeTable extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> originalUsers;
  final dynamic dbs;
  final Function(int) updateUser; // Función para actualizar un usuario.
  final Function(int) deleteUser; // Función para eliminar un usuario.
  final Function(int) showScholarshipInfo; // Función para mostrar la información de becas.
  final int rowsPerPage;

  /// Constructor de `HomeTable`.
  ///
  /// Parámetros requeridos:
  /// - `users`: Lista de mapas que contienen los datos de los usuarios.
  /// - `originalUsers`: Lista original de los usuarios para detectar cambios.
  /// - `dbs`: Servicio de base de datos que se utiliza para interactuar con los usuarios.
  /// - `updateUser`: Función que se ejecuta cuando se actualiza un usuario.
  /// - `deleteUser`: Función que se ejecuta cuando se elimina un usuario.
  /// - `showScholarshipInfo`: Función que muestra la información de las becas de un usuario.
  /// - `rowsPerPage`: Cantidad de filas por página en la tabla.
  const HomeTable({super.key,
    required this.users,
    required this.originalUsers,
    required this.dbs,
    required this.updateUser,
    required this.deleteUser,
    required this.showScholarshipInfo, // Añadido para mostrar becas.
    required this.rowsPerPage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: PaginatedDataTable(
              // Define la cantidad de filas por página en la tabla.
              rowsPerPage: rowsPerPage,
              // Definición de las columnas de la tabla.
              columns: const [
                DataColumn(label: Text('Nombre de usuario')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Cédula')),
                DataColumn(label: Text('Teléfono')),
                DataColumn(label: Text('Ubicación')),
                DataColumn(label: Text('Deporte')),
                DataColumn(label: Text('Beca')),
                DataColumn(label: Text('')),
              ],
              // Fuente de los datos de la tabla.
              source: UserDataTableSource(users, updateUser, deleteUser, showScholarshipInfo), // Actualizado con la funcionalidad de becas.
              columnSpacing: constraints.maxWidth * 0.02, // Espaciado entre columnas.
            ),
          ),
        );
      },
    );
  }
}
