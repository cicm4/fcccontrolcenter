import 'package:flutter/material.dart';

class ScholarshipPopup extends StatelessWidget {
  final Map<String, dynamic> scholarshipData;
  final Future<void> Function(String) removeFile;

  const ScholarshipPopup({
    Key? key,
    required this.scholarshipData,
    required this.removeFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Información de Beca para ${scholarshipData['uid']}'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Nombre de Cuenta Bancaria: ${scholarshipData['bankAccountName']}'),
            Text('Número de Cuenta Bancaria: ${scholarshipData['bankaccount']}'),
            Text('Cedula: ${scholarshipData['gid']}'),
            // Add other scholarship details here
            // Each file has a URL and a name in the scholarshipData, use those to create buttons to delete them
            ElevatedButton(
              onPressed: () => removeFile('matriculaURL'),
              child: Text('Eliminar Matricula'),
            ),
            ElevatedButton(
              onPressed: () => removeFile('horarioURL'),
              child: Text('Eliminar Horario'),
            ),
            ElevatedButton(
              onPressed: () => removeFile('soporteURL'),
              child: Text('Eliminar Soporte'),
            ),
            ElevatedButton(
              onPressed: () => removeFile('bankaccountURL'),
              child: Text('Eliminar Cuenta Bancaria'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cerrar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
