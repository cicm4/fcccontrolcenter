import 'package:flutter/material.dart';
import 'package:fcccontrolcenter/services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:intl/intl.dart';

/// `CreateUserButton`: Un botón que permite la creación de usuarios individuales o masivos.
///
/// Este botón, al ser presionado, muestra un diálogo con dos opciones: registrar un usuario individualmente
/// o registrar varios usuarios a través de un archivo CSV. Utiliza los servicios de autenticación proporcionados por `AuthService`.
class CreateUserButton extends StatelessWidget {
  final AuthService authService;
  final Function refreshUserTable;

  /// Constructor de `CreateUserButton`.
  ///
  /// - `authService`: Instancia del servicio de autenticación.
  /// - `refreshUserTable`: Función que actualiza la tabla de usuarios después de la creación.
  const CreateUserButton({
    super.key,
    required this.authService,
    required this.refreshUserTable,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // Al presionar el botón, se muestra un diálogo para elegir el tipo de registro.
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
                      _showSingleUserDialog(context); // Llama al diálogo de creación individual.
                    },
                    child: const Text('Registrar Uno'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showBulkUserDialog(context); // Llama al diálogo de creación masiva.
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

  /// Muestra un diálogo para registrar un solo usuario.
  void _showSingleUserDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController gidController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    String location = 'Medellin'; // Ubicación predeterminada
    String sport = 'Tennis'; // Deporte predeterminado
    String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Fecha actual como predeterminada.

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
                  decoration: const InputDecoration(labelText: 'Cédula'),
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
                Text('Fecha de Inicio: $startDate'), // Fecha predeterminada
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
                // Toma los valores ingresados por el usuario.
                String email = emailController.text.trim();
                String name = nameController.text.trim();
                String gid = gidController.text.trim();
                String phone = phoneController.text.trim();
                String password = '$name${DateTime.now().year}'; // Contraseña: nombre + año actual

                // Registra el usuario con los datos proporcionados.
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

                // Muestra mensajes según el resultado del registro.
                if (result == 'Success') {
                  await refreshUserTable();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario creado exitosamente')),
                  );
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

  /// Muestra un diálogo para registrar usuarios masivamente utilizando un archivo CSV.
  void _showBulkUserDialog(BuildContext context) async {
    // Abre un selector de archivos para seleccionar un archivo CSV.
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String csvContent = file.readAsStringSync();

      // Convierte el contenido del CSV a una lista de valores.
      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvContent);

      bool hasError = false;

      // Procesa las filas del CSV, comenzando después del encabezado.
      for (var row in rowsAsListOfValues.skip(1)) {
        String email = row[0];
        String name = row[1];
        String gid = row[2];
        String location = row[3];
        String phone = row[4];
        String sport = row[5];
        String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String password = '$name${DateTime.now().year}'; // Contraseña: nombre + año actual

        // Intenta registrar al usuario con los datos proporcionados.
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

        // Si ocurre un error, lo registra.
        if (result != 'Success') {
          hasError = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear el usuario $email: $result')),
          );
        }
      }

      // Si no hubo errores, muestra un mensaje de éxito.
      if (!hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proceso de creación masiva completado')),
        );
      }

      refreshUserTable(); // Actualiza la tabla de usuarios.
    }
  }
}
