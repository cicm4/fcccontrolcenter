import 'package:flutter/material.dart';

class UserDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> users;
  final Function(int) updateUser;
  final Function(int) deleteUser;

  UserDataTableSource(this.users, this.updateUser, this.deleteUser);

  @override
  DataRow getRow(int index) {
    final user = users[index];

    // Ensure that location and sport have valid initial values
    if (!['Medellin', 'Llanogrande'].contains(user['location'])) {
      user['location'] = 'Medellin';
    }
    if (!['Tennis', 'Golf'].contains(user['sport'])) {
      user['sport'] = 'Tennis';
    }

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
