// Required imports for home.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/database_service.dart';

class Home extends StatelessWidget {
  final DBService dbs;

  const Home({super.key, required this.dbs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0b512d),
        title: Text(
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
        decoration: BoxDecoration(
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
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 20),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/defaultimage.jpg'),
                ),
                SizedBox(width: 20),
                Text(
                  "Vista de administrador",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Table(
                          border: TableBorder.all(color: Colors.black),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Color(0xFF0b512d),
                              ),
                              children: [
                                _buildTableCell('Nombre de usuario', true),
                                _buildTableCell('Tipo de ayuda', true),
                                _buildTableCell('Cedula', true),
                                _buildTableCell('Telefono', true),
                                _buildTableCell('Previsualizacion de Mensaje', true),
                                _buildTableCell('Numero de cuenta', true),
                                _buildTableCell('Archivo de prueba', true),
                              ],
                            ),
                            for (int i = 0; i < 3; i++)
                              TableRow(
                                decoration: BoxDecoration(
                                  color: i % 2 == 0 ? Colors.white : Color(0xFFe6e6e3),
                                ),
                                children: [
                                  _buildTableCell('Usuario $i', false),
                                  _buildTableCell('Ayuda $i', false),
                                  _buildTableCell('Cedula $i', false),
                                  _buildTableCell('Telefono $i', false),
                                  _buildTableCell('Mensaje $i', false),
                                  _buildTableCell('Cuenta $i', false),
                                  _buildTableCellWithButton(),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, bool isHeader) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
          color: isHeader ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTableCellWithButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // Handle file opening logic here
        },
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF0b512d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "Archivo",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
