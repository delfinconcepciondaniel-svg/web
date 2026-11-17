import 'package:flutter/material.dart';

import 'layout.dart';
import 'repositorio.dart';
import 'tema.dart';

void main() {
  runApp(const RutaExpressApp());
}

class RutaExpressApp extends StatelessWidget {
  const RutaExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RutaExpress · Gestión Integral',
      theme: AppTema.theme,
      home: AppShell(repositorio: Repositorio()),
    );
  }
}
