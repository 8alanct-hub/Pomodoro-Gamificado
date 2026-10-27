import 'package:flutter/material.dart';

import 'colores.dart';

/// Tema de la app: colores UTB y fuente Nunito, en modo claro.
abstract final class Tema {
  static ThemeData get claro {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colores.primario,
      primary: Colores.primario,
      error: Colores.error,
      surface: Colores.blanco,
    );
    return ThemeData(
      colorScheme: scheme,
      fontFamily: 'Nunito',
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'Nunito',
        bodyColor: Colores.texto,
        displayColor: Colores.texto,
      ),
      scaffoldBackgroundColor: Colores.blanco,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colores.blanco,
        foregroundColor: Colores.texto,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          foregroundColor: Colores.primario,
          side: const BorderSide(color: Colores.primario, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colores.primario,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colores.blanco,
        surfaceTintColor: Colores.blanco,
        modalBarrierColor: Color(0x7314173A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colores.superficie,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.borde),
        ),
      ),
    );
  }
}
