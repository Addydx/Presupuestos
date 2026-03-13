/// EJEMPLOS DE USO: MÓDULO DE FINANZAS
///
/// Este archivo contiene ejemplos prácticos de cómo usar el módulo de finanzas
/// en la aplicación de presupuestos.

import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';

void ejemplosCalculadoraFinanzas() {
  final calculadora = CalculadoraFinanzas();

  // ============================================================================
  // EJEMPLO 1: Presupuesto simple con imprevistos, utilidad e IVA
  // ============================================================================
  print('=== EJEMPLO 1: Presupuesto Simple ===\n');

  final totalMateriales = 5000.0; // $5,000
  final totalManoObra = 3000.0; // $3,000
  final totalEquipos = 2000.0; // $2,000

  final finanzas1 = Finanzas(
    porcentajeImprevistos: 5.0, // 5% de imprevistos
    porcentajeUtilidad: 20.0, // 20% de utilidad
    aplicarIVA: true, // Aplicar IVA
  );

  final resultado1 = calculadora.calcularTodo(
    totalMateriales: totalMateriales,
    totalManoObra: totalManoObra,
    totalEquipos: totalEquipos,
    finanzas: finanzas1,
  );

  print('Costos directos:');
  print('  Materiales: ${calculadora.formatoMoneda(totalMateriales)}');
  print('  Mano de obra: ${calculadora.formatoMoneda(totalManoObra)}');
  print('  Equipos: ${calculadora.formatoMoneda(totalEquipos)}');
  print('  Total: ${calculadora.formatoMoneda(resultado1["costoDirecto"]!)}');
  print('');
  print('Cálculos financieros:');
  print(
    '  Imprevistos (5%): ${calculadora.formatoMoneda(resultado1["imprevistos"]!)}',
  );
  print('  Subtotal: ${calculadora.formatoMoneda(resultado1["subtotal"]!)}');
  print(
    '  Utilidad (20%): ${calculadora.formatoMoneda(resultado1["utilidad"]!)}',
  );
  print(
    '  Precio final: ${calculadora.formatoMoneda(resultado1["precioFinal"]!)}',
  );
  print('  IVA (16%): ${calculadora.formatoMoneda(resultado1["iva"]!)}');
  print(
    '  TOTAL FINAL: ${calculadora.formatoMoneda(resultado1["totalFinal"]!)}',
  );
  print('');

  // ============================================================================
  // EJEMPLO 2: Presupuesto SIN IVA (para cliente exento)
  // ============================================================================
  print('=== EJEMPLO 2: Presupuesto sin IVA ===\n');

  final finanzas2 = Finanzas(
    porcentajeImprevistos: 10.0, // 10% imprevistos
    porcentajeUtilidad: 25.0, // 25% utilidad
    aplicarIVA: false, // No aplicar IVA
  );

  final resultado2 = calculadora.calcularTodo(
    totalMateriales: totalMateriales,
    totalManoObra: totalManoObra,
    totalEquipos: totalEquipos,
    finanzas: finanzas2,
  );

  print(
    'Costos directos: ${calculadora.formatoMoneda(resultado2["costoDirecto"]!)}',
  );
  print(
    'Imprevistos (10%): ${calculadora.formatoMoneda(resultado2["imprevistos"]!)}',
  );
  print('Subtotal: ${calculadora.formatoMoneda(resultado2["subtotal"]!)}');
  print(
    'Utilidad (25%): ${calculadora.formatoMoneda(resultado2["utilidad"]!)}',
  );
  print(
    'Precio final: ${calculadora.formatoMoneda(resultado2["precioFinal"]!)}',
  );
  print('IVA: NO APLICA');
  print('TOTAL FINAL: ${calculadora.formatoMoneda(resultado2["totalFinal"]!)}');
  print('');

  // ============================================================================
  // EJEMPLO 3: Presupuesto con porcentajes bajos (cliente frecuente)
  // ============================================================================
  print('=== EJEMPLO 3: Presupuesto con descuento (cliente frecuente) ===\n');

  final finanzas3 = Finanzas(
    porcentajeImprevistos: 2.0, // 2% imprevistos mínimos
    porcentajeUtilidad: 10.0, // 10% utilidad reducida
    aplicarIVA: true,
  );

  final resultado3 = calculadora.calcularTodo(
    totalMateriales: totalMateriales,
    totalManoObra: totalManoObra,
    totalEquipos: totalEquipos,
    finanzas: finanzas3,
  );

  print(
    'Costos directos: ${calculadora.formatoMoneda(resultado3["costoDirecto"]!)}',
  );
  print(
    'Imprevistos (2%): ${calculadora.formatoMoneda(resultado3["imprevistos"]!)}',
  );
  print('Subtotal: ${calculadora.formatoMoneda(resultado3["subtotal"]!)}');
  print(
    'Utilidad (10%): ${calculadora.formatoMoneda(resultado3["utilidad"]!)}',
  );
  print(
    'Precio final: ${calculadora.formatoMoneda(resultado3["precioFinal"]!)}',
  );
  print('IVA (16%): ${calculadora.formatoMoneda(resultado3["iva"]!)}');
  print('TOTAL FINAL: ${calculadora.formatoMoneda(resultado3["totalFinal"]!)}');
  print('');

  // ============================================================================
  // EJEMPLO 4: Comparación de diferentes escenarios
  // ============================================================================
  print('=== EJEMPLO 4: Comparación de Escenarios ===\n');

  final escenarios = [
    (
      'Bajo (5%+20%+IVA)',
      Finanzas(
        porcentajeImprevistos: 5,
        porcentajeUtilidad: 20,
        aplicarIVA: true,
      ),
    ),
    (
      'Medio (7%+25%+IVA)',
      Finanzas(
        porcentajeImprevistos: 7,
        porcentajeUtilidad: 25,
        aplicarIVA: true,
      ),
    ),
    (
      'Alto (10%+30%+IVA)',
      Finanzas(
        porcentajeImprevistos: 10,
        porcentajeUtilidad: 30,
        aplicarIVA: true,
      ),
    ),
  ];

  print(
    'Comparativa para un costo directo de ${calculadora.formatoMoneda(resultado1["costoDirecto"]!)}\n',
  );

  for (final (nombre, finanzas) in escenarios) {
    final resultado = calculadora.calcularTodo(
      totalMateriales: totalMateriales,
      totalManoObra: totalManoObra,
      totalEquipos: totalEquipos,
      finanzas: finanzas,
    );

    final totalFinal = resultado['totalFinal']!;
    final margen = totalFinal - resultado1['costoDirecto']!;
    final porcentajeMargen = (margen / resultado1['costoDirecto']!) * 100;

    print('$nombre:');
    print('  Total: ${calculadora.formatoMoneda(totalFinal)}');
    print(
      '  Margen: ${calculadora.formatoMoneda(margen)} (${porcentajeMargen.toStringAsFixed(1)}%)',
    );
    print('');
  }

  // ============================================================================
  // EJEMPLO 5: Cálculos individuales sin usar calcularTodo()
  // ============================================================================
  print('=== EJEMPLO 5: Cálculos Individuales ===\n');

  final costoDirecto = calculadora.costoDirecto(
    totalMateriales: 5000,
    totalManoObra: 3000,
    totalEquipos: 2000,
  );

  final imprevistos = calculadora.imprevistos(
    costoDirecto: costoDirecto,
    porcentajeImprevistos: 5,
  );

  final subtotal = calculadora.subtotal(
    costoDirecto: costoDirecto,
    imprevistos: imprevistos,
  );

  final utilidad = calculadora.utilidad(
    subtotal: subtotal,
    porcentajeUtilidad: 20,
  );

  final precioFinal = calculadora.precioFinal(
    subtotal: subtotal,
    utilidad: utilidad,
  );

  final iva = calculadora.iva(precioFinal: precioFinal, aplicarIVA: true);

  final totalFinal = calculadora.totalFinal(precioFinal: precioFinal, iva: iva);

  print('Paso a paso:');
  print('1. Costo directo = ${calculadora.formatoMoneda(costoDirecto)}');
  print('2. Imprevistos (5%) = ${calculadora.formatoMoneda(imprevistos)}');
  print('3. Subtotal = ${calculadora.formatoMoneda(subtotal)}');
  print('4. Utilidad (20%) = ${calculadora.formatoMoneda(utilidad)}');
  print('5. Precio final = ${calculadora.formatoMoneda(precioFinal)}');
  print('6. IVA (16%) = ${calculadora.formatoMoneda(iva)}');
  print('7. TOTAL FINAL = ${calculadora.formatoMoneda(totalFinal)}');
  print('');

  // ============================================================================
  // EJEMPLO 6: Análisis de margen de ganancia
  // ============================================================================
  print('=== EJEMPLO 6: Análisis de Márgenes ===\n');

  final resultado6 = calculadora.calcularTodo(
    totalMateriales: 5000,
    totalManoObra: 3000,
    totalEquipos: 2000,
    finanzas: Finanzas(
      porcentajeImprevistos: 5,
      porcentajeUtilidad: 20,
      aplicarIVA: true,
    ),
  );

  final costoDirecto6 = resultado6['costoDirecto']!;
  final utilidadBruta6 = resultado6['utilidad']!;
  final totalFinal6 = resultado6['totalFinal']!;

  final margenBruto = (utilidadBruta6 / costoDirecto6) * 100;
  final margenVenta = ((totalFinal6 - costoDirecto6) / totalFinal6) * 100;
  final rentabilidad = ((utilidadBruta6 / costoDirecto6) * 100);

  print('Análisis de márgenes:');
  print('  Costo directo: ${calculadora.formatoMoneda(costoDirecto6)}');
  print('  Utilidad bruta: ${calculadora.formatoMoneda(utilidadBruta6)}');
  print('  Total final: ${calculadora.formatoMoneda(totalFinal6)}');
  print('');
  print('Indicadores:');
  print('  Margen bruto: ${margenBruto.toStringAsFixed(2)}%');
  print('  Margen de venta: ${margenVenta.toStringAsFixed(2)}%');
  print('  Rentabilidad: ${rentabilidad.toStringAsFixed(2)}%');
}

void main() {
  ejemplosCalculadoraFinanzas();
}
