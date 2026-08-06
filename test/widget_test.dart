import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:presupuesto_app/main.dart';

void main() {
  testWidgets('MyApp muestra la pantalla de bienvenida (splash)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Presupuesto App'), findsOneWidget);
    expect(find.text('Gestión profesional de presupuestos'), findsOneWidget);

    // El splash programa una navegación diferida con Future.delayed; se
    // desmonta el árbol y se avanza el reloj para vaciar ese timer pendiente
    // antes de terminar el test (evita "A Timer is still pending").
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(seconds: 4));
  });
}
