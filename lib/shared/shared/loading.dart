// Pantalla de carga predeterminada básica para la aplicación.
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Color de fondo de la pantalla de carga.
      child: const SpinKitFadingCircle(
        color: Colors.white, // Color del spinner.
        size: 50.0, // Tamaño del spinner.
      ),
    );
  }
}
