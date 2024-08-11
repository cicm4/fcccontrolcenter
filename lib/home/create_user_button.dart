import 'package:flutter/material.dart';
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class CreateUserButton extends StatelessWidget {
  final AuthService authService;
  final Function refreshUserTable;

  const CreateUserButton({
    Key? key,
    required this.authService,
    required this.refreshUserTable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              alignment: Alignment.center,
              title: const Text(
                'Crear Usuario',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showSingleUserDialog(context);
                    },
                    child: const Text('Registrar Uno'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showBulkUserDialog(context);
                    },
                    child: const Text('Registrar Varios'),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: const Text('Crear Usuario'),
    );
  }

  /// Shows a dialog for single user registration.
  void _showSingleUserDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController gidController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    String location = 'Medellin'; // Default location
    String sport = 'Tennis'; // Default sport
    String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Current date

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registrar Nuevo Usuario'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                TextField(
                  controller: gidController,
                  decoration: const InputDecoration(labelText: 'Cedula'),
                ),
                DropdownButtonFormField<String>(
                  value: location,
                  items: ['Medellin', 'Llanogrande'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    location = newValue!;
                  },
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                DropdownButtonFormField<String>(
                  value: sport,
                  items: ['Tennis', 'Golf'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    sport = newValue!;
                  },
                  decoration: const InputDecoration(labelText: 'Deporte'),
                ),
                const SizedBox(height: 10),
                Text('Fecha de Inicio: $startDate'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Crear'),
              onPressed: () async {
                String email = emailController.text.trim();
                String name = nameController.text.trim();
                String gid = gidController.text.trim();
                String phone = phoneController.text.trim();
                String password = '$name${DateTime.now().year}'; // Password: name + current year

                String result = await authService.registerWithEmailAndPass(
                  emailAddress: email,
                  password: password,
                  name: name,
                  phone: phone,
                  sport: sport,
                  gid: gid,
                  location: location,
                  startDate: startDate,
                );

                if (result == 'Success') {
                  await refreshUserTable();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario creado exitosamente')),
                  ); // Reload the user table
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $result')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog for bulk user registration via CSV.
  void _showBulkUserDialog(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String csvContent = file.readAsStringSync();

      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvContent);

      bool hasError = false;

      // Skip header row if it exists
      for (var row in rowsAsListOfValues.skip(1)) {
        String email = row[0];
        String name = row[1];
        String gid = row[2];
        String location = row[3];
        String phone = row[4];
        String sport = row[5];
        String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String password = '$name${DateTime.now().year}'; // Password: name + current year

        String result = await authService.registerWithEmailAndPass(
          emailAddress: email,
          password: password,
          name: name,
          phone: phone,
          sport: sport,
          gid: gid,
          location: location,
          startDate: startDate,
        );

        if (result != 'Success') {
          hasError = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear el usuario $email: $result')),
          );
        }
      }

      if (!hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proceso de creación masiva completado')),
        );
      }

      refreshUserTable(); // Reload the user table
    }
  }
}
