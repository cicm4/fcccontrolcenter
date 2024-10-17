import 'package:flutter/material.dart';

/// `UserDataTableSource`
/// 
/// Esta clase implementa una fuente de datos para una tabla de datos (`DataTable`) que muestra la información de los usuarios.
/// Permite editar directamente la información de los usuarios desde la tabla y realizar acciones como eliminar usuarios o mostrar detalles de la beca.
class UserDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> users; // Lista de usuarios
  final Function(int) updateUser; // Función para actualizar un usuario
  final Function(int) deleteUser; // Función para eliminar un usuario
  final Function(int) showScholarshipInfo; // Función para mostrar información de la beca

  UserDataTableSource(this.users, this.updateUser, this.deleteUser, this.showScholarshipInfo);

  @override
  DataRow getRow(int index) {
    final user = users[index];

    // Asignar valores iniciales válidos a la ubicación y deporte si son incorrectos
    if (!['Medellin', 'Llanogrande'].contains(user['location'])) {
      user['location'] = 'Medellin';
    }
    if (!['Tennis', 'Golf'].contains(user['sport'])) {
      user['sport'] = 'Tennis';
    }

    return DataRow(cells: [
      // Campo editable para el nombre del usuario
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
      // Campo editable para el email del usuario
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
      // Campo editable para la cédula del usuario
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
      // Campo editable para el teléfono del usuario
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
      // Selector para la ubicación del usuario
      DataCell(
        DropdownButtonFormField<String>(
          value: user['location'],
          onChanged: (String? newValue) {
            user['location'] = newValue;
          },
          items: ['Medellin', 'Llanogrande'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      // Selector para el deporte del usuario
      DataCell(
        DropdownButtonFormField<String>(
          value: user['sport'],
          onChanged: (String? newValue) {
            user['sport'] = newValue;
          },
          items: ['Tennis', 'Golf'].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      // Botón para mostrar la información de la beca del usuario
      DataCell(ElevatedButton(
        onPressed: () {
          showScholarshipInfo(index);
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
      // Icono para eliminar el usuario
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
