import 'package:flutter/material.dart';

import 'layout.dart';
import 'repositorio.dart';
import 'tema.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repositorio = Repositorio();
  await repositorio.cargarDesdeApi();
  runApp(RutaExpressApp(repositorio: repositorio));
}

class RutaExpressApp extends StatelessWidget {
  const RutaExpressApp({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RutaExpress · Gestión Integral',
      theme: AppTema.theme,
      home: AppShell(repositorio: repositorio),
    );
  }
}
