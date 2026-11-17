import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('RutaExpress dashboard renders', (WidgetTester tester) async {
    await tester.pumpWidget(const RutaExpressApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido, Administrador'), findsOneWidget);
    expect(find.text('Nuevo envío'), findsOneWidget);
    expect(find.text('Últimos envíos registrados'), findsOneWidget);
  });

  testWidgets('navega por todos los modulos', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const RutaExpressApp());
    await tester.pumpAndSettle();

    for (final modulo in ['Envíos', 'Paquetes', 'Rutas', 'Repartidores', 'Pagos', 'Clientes', 'Empleados', 'Reportes', 'Panel de control']) {
      await tester.tap(find.text(modulo).first);
      await tester.pumpAndSettle();
      expect(find.text(modulo), findsWidgets);
    }
  });
}
