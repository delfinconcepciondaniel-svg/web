import 'package:flutter/material.dart';

class AppColores {
  static const primary = Color(0xFF1D4ED8);
  static const primaryDark = Color(0xFF1E3A8A);
  static const primaryLight = Color(0xFFEFF6FF);
  static const accent = Color(0xFFF59E0B);
  static const fondo = Color(0xFFF4F6FA);
  static const tarjeta = Colors.white;
  static const texto = Color(0xFF0F172A);
  static const textoSecundario = Color(0xFF64748B);
  static const borde = Color(0xFFE2E8F0);
  static const sidebar = Color(0xFF101B33);
  static const sidebarActivo = Color(0xFF1E40AF);
  static const verde = Color(0xFF059669);
  static const naranja = Color(0xFFD97706);
  static const rojo = Color(0xFFDC2626);
}

class AppTema {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColores.primary,
        primary: AppColores.primary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColores.fondo,
      fontFamily: 'Segoe UI',
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColores.texto, letterSpacing: -0.5),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColores.texto),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColores.texto),
        bodyMedium: TextStyle(fontSize: 14, color: AppColores.texto),
        bodySmall: TextStyle(fontSize: 12, color: AppColores.textoSecundario),
      ),
      cardTheme: CardThemeData(
        color: AppColores.tarjeta,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColores.borde)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColores.borde)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColores.borde)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColores.primary, width: 2)),
        labelStyle: const TextStyle(color: AppColores.textoSecundario, fontSize: 13),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColores.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColores.primary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          side: const BorderSide(color: AppColores.borde),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
    return base;
  }
}

BoxShadow get sombraTarjeta => BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4));
