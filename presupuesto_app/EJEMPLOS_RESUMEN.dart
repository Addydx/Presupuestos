/// EJEMPLOS DE USO: PANTALLA DE RESUMEN
///
/// Este archivo contiene ejemplos de cómo usar la pantalla de resumen
/// en diferentes contextos.

import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/screens/presupuesto/resumen_presupuesto_screen.dart';

// ============================================================================
// EJEMPLO 1: Abrir el resumen desde una lista de presupuestos
// ============================================================================

void ejemplo1_AbrirResumenDesdePresupuesto(
  BuildContext context,
  String presupuestoId,
) {
  // Simular obtención de datos desde Hive
  final materiales = <MaterialPresupuesto>[
    MaterialPresupuesto(
      id: '1',
      nombre: 'Cemento Portland',
      cantidad: 20,
      precioUnitario: 50,
    ),
    MaterialPresupuesto(
      id: '2',
      nombre: 'Arena fina',
      cantidad: 15,
      precioUnitario: 35,
    ),
  ];

  final manoObra = <ManoObra>[
    ManoObra(
      tipoPago: TipoPago.porDia,
      rol: 'Maestro de obra',
      cantidadPersonas: 2,
      diasEstimados: 30,
      costoPorDia: 100,
    ),
  ];

  final equipos = <Equipo>[
    Equipo(nombre: 'Excavadora', dias: 10, costoPorDia: 500),
  ];

  final finanzas = Finanzas(
    porcentajeImprevistos: 5,
    porcentajeUtilidad: 20,
    aplicarIVA: true,
  );

  // Navegar a la pantalla de resumen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) => ResumenPresupuestoScreen(
            materiales: materiales,
            equipos: equipos,
            manoObra: manoObra,
            finanzas: finanzas,
            titulo: 'Presupuesto Casa 100m²',
            fecha: DateTime.now(),
          ),
    ),
  );
}

// ============================================================================
// EJEMPLO 2: Generar datos de prueba para el resumen
// ============================================================================

class DatosPresupuestoPrueba {
  static final materiales = <MaterialPresupuesto>[
    MaterialPresupuesto(
      id: '1',
      nombre: 'Cemento Portland 50kg',
      cantidad: 20,
      precioUnitario: 50,
    ),
    MaterialPresupuesto(
      id: '2',
      nombre: 'Arena fina tamizada',
      cantidad: 15,
      precioUnitario: 35,
    ),
    MaterialPresupuesto(
      id: '3',
      nombre: 'Varilla de acero #3',
      cantidad: 100,
      precioUnitario: 25,
    ),
    MaterialPresupuesto(
      id: '4',
      nombre: 'Ladrillos cerámicos 6h',
      cantidad: 500,
      precioUnitario: 2.5,
    ),
    MaterialPresupuesto(
      id: '5',
      nombre: 'Tuberías PVC 4"',
      cantidad: 50,
      precioUnitario: 45,
    ),
  ];

  static final manoObra = <ManoObra>[
    ManoObra(
      tipoPago: TipoPago.porDia,
      rol: 'Maestro de obra',
      cantidadPersonas: 1,
      diasEstimados: 40,
      costoPorDia: 150,
    ),
    ManoObra(
      tipoPago: TipoPago.porDia,
      rol: 'Peón',
      cantidadPersonas: 3,
      diasEstimados: 40,
      costoPorDia: 60,
    ),
    ManoObra(
      tipoPago: TipoPago.porContrato,
      rol: 'Electricista',
      montoContrato: 2500,
    ),
    ManoObra(
      tipoPago: TipoPago.porContrato,
      rol: 'Plomero',
      montoContrato: 2000,
    ),
  ];

  static final equipos = <Equipo>[
    Equipo(nombre: 'Excavadora', dias: 5, costoPorDia: 500),
    Equipo(nombre: 'Compactador', dias: 3, costoPorDia: 300),
    Equipo(nombre: 'Andamio metálico', dias: 40, costoPorDia: 50),
  ];

  static final finanzas = Finanzas(
    porcentajeImprevistos: 5,
    porcentajeUtilidad: 20,
    aplicarIVA: true,
  );
}

// ============================================================================
// EJEMPLO 3: Widget que muestra el resumen en un diálogo
// ============================================================================

void ejemplo3_MostrarResumenEnDialogo(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          child: ResumenPresupuestoScreen(
            materiales: DatosPresupuestoPrueba.materiales,
            equipos: DatosPresupuestoPrueba.equipos,
            manoObra: DatosPresupuestoPrueba.manoObra,
            finanzas: DatosPresupuestoPrueba.finanzas,
            titulo: 'Presupuesto Casa 100m²',
            fecha: DateTime.now(),
          ),
        ),
  );
}

// ============================================================================
// EJEMPLO 4: Pantalla que muestra lista de presupuestos con botón "Ver Resumen"
// ============================================================================

class ListaPresupuestosConResumen extends StatelessWidget {
  const ListaPresupuestosConResumen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Presupuestos')),
      body: ListView(
        children: [
          _buildPresupuestoItem(
            context,
            'Casa 100m²',
            'Remodelación completa',
            '\$45,320.50',
          ),
          _buildPresupuestoItem(
            context,
            'Oficina 50m²',
            'Construcción nueva',
            '\$28,750.00',
          ),
          _buildPresupuestoItem(
            context,
            'Local comercial',
            'Reparaciones varias',
            '\$12,500.75',
          ),
        ],
      ),
    );
  }

  Widget _buildPresupuestoItem(
    BuildContext context,
    String titulo,
    String descripcion,
    String total,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(titulo),
        subtitle: Text(descripcion),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              total,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () {
                // Aquí se abre el resumen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ResumenPresupuestoScreen(
                          materiales: DatosPresupuestoPrueba.materiales,
                          equipos: DatosPresupuestoPrueba.equipos,
                          manoObra: DatosPresupuestoPrueba.manoObra,
                          finanzas: DatosPresupuestoPrueba.finanzas,
                          titulo: titulo,
                          fecha: DateTime.now(),
                        ),
                  ),
                );
              },
              child: const Text('Ver'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 5: Generar resumen para un presupuesto sin detalles
// ============================================================================

ResumenPresupuestoScreen generarResumenVacio({required String titulo}) {
  return ResumenPresupuestoScreen(
    materiales: [],
    equipos: [],
    manoObra: [],
    finanzas: Finanzas(),
    titulo: titulo,
    fecha: DateTime.now(),
  );
}

// ============================================================================
// EJEMPLO 6: Comparar dos presupuestos lado a lado
// ============================================================================

void ejemplo6_CompararDosPresupuestos(BuildContext context) {
  final presupuesto1 = ResumenPresupuestoScreen(
    materiales: DatosPresupuestoPrueba.materiales,
    equipos: DatosPresupuestoPrueba.equipos,
    manoObra: DatosPresupuestoPrueba.manoObra,
    finanzas: Finanzas(
      porcentajeImprevistos: 5,
      porcentajeUtilidad: 20,
      aplicarIVA: true,
    ),
    titulo: 'Presupuesto Opción 1',
    fecha: DateTime.now(),
  );

  final presupuesto2 = ResumenPresupuestoScreen(
    materiales: DatosPresupuestoPrueba.materiales,
    equipos: DatosPresupuestoPrueba.equipos,
    manoObra: DatosPresupuestoPrueba.manoObra,
    finanzas: Finanzas(
      porcentajeImprevistos: 10,
      porcentajeUtilidad: 25,
      aplicarIVA: true,
    ),
    titulo: 'Presupuesto Opción 2',
    fecha: DateTime.now(),
  );

  // Mostrar en zwei tabs
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Comparar Presupuestos'),
          content: const Text(
            'Opción implementada: Ver presupuestos por separado',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => presupuesto1),
                );
              },
              child: const Text('Opción 1'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => presupuesto2),
                );
              },
              child: const Text('Opción 2'),
            ),
          ],
        ),
  );
}

// ============================================================================
// EJEMPLO 7: Resumen con datos más realistas (construcción real)
// ============================================================================

class PresupuestoRealista {
  static final casa100m2Materiales = <MaterialPresupuesto>[
    // Cimentación
    MaterialPresupuesto(
      id: 'm1',
      nombre: 'Cemento Portland 50kg',
      cantidad: 100,
      precioUnitario: 50,
    ),
    MaterialPresupuesto(
      id: 'm2',
      nombre: 'Arena para concreto',
      cantidad: 60,
      precioUnitario: 40,
    ),
    MaterialPresupuesto(
      id: 'm3',
      nombre: 'Grava #6',
      cantidad: 80,
      precioUnitario: 35,
    ),
    // Estructura
    MaterialPresupuesto(
      id: 'm4',
      nombre: 'Varilla de acero #4',
      cantidad: 200,
      precioUnitario: 30,
    ),
    // Mampostería
    MaterialPresupuesto(
      id: 'm5',
      nombre: 'Ladrillos 6h cerámicos',
      cantidad: 2000,
      precioUnitario: 2.5,
    ),
    // Acabados
    MaterialPresupuesto(
      id: 'm6',
      nombre: 'Cemento blanco 50kg',
      cantidad: 50,
      precioUnitario: 70,
    ),
    MaterialPresupuesto(
      id: 'm7',
      nombre: 'Pintura acrílica galón',
      cantidad: 20,
      precioUnitario: 180,
    ),
    // Instalaciones
    MaterialPresupuesto(
      id: 'm8',
      nombre: 'Tuberías PVC 4"',
      cantidad: 100,
      precioUnitario: 45,
    ),
    MaterialPresupuesto(
      id: 'm9',
      nombre: 'Cable eléctrico #10',
      cantidad: 500,
      precioUnitario: 2,
    ),
  ];

  static final casa100m2ManoObra = <ManoObra>[
    // Mano de obra por días
    ManoObra(
      tipoPago: TipoPago.porDia,
      rol: 'Maestro de obra',
      cantidadPersonas: 1,
      diasEstimados: 60,
      costoPorDia: 200,
    ),
    ManoObra(
      tipoPago: TipoPago.porDia,
      rol: 'Peón',
      cantidadPersonas: 4,
      diasEstimados: 60,
      costoPorDia: 80,
    ),
    // Mano de obra por contrato
    ManoObra(
      tipoPago: TipoPago.porContrato,
      rol: 'Electricista',
      montoContrato: 5000,
    ),
    ManoObra(
      tipoPago: TipoPago.porContrato,
      rol: 'Plomero',
      montoContrato: 4000,
    ),
  ];

  static final casa100m2Equipos = <Equipo>[
    Equipo(nombre: 'Excavadora', dias: 10, costoPorDia: 600),
    Equipo(nombre: 'Compactador', dias: 5, costoPorDia: 400),
    Equipo(nombre: 'Andamio metálico', dias: 60, costoPorDia: 50),
    Equipo(nombre: 'Mezcladora de concreto', dias: 30, costoPorDia: 100),
  ];

  static final casa100m2Finanzas = Finanzas(
    porcentajeImprevistos: 5,
    porcentajeUtilidad: 20,
    aplicarIVA: true,
  );
}
