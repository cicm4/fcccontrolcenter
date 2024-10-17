import 'package:flutter/material.dart';

// Definición del tema general de la aplicación.
ThemeData generalTheme = ThemeData(
  primaryColor: const Color(0xFF0b512d), // Color principal del tema.
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff2e7d32), // Color base para generar la paleta.
    brightness: Brightness.dark, // Configuración del brillo del tema.
  ),
);
