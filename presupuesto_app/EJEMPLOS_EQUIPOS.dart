// EJEMPLOS DE USO - SERVICIO DE EQUIPOS

import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/services/equipos_service.dart';

void ejemplosUsoEquipos() async {
  // ==================== INICIALIZACIÓN ====================

  final service = EquiposService();
  await service.initialize(); // IMPORTANTE: Llamar primero

  // ==================== OPERACIONES CRUD ====================

  // Crear un nuevo equipo
  final grua = Equipo(
    nombre: 'Grúa Telescópica 50T',
    costoPorDia: 350.00,
    dias: 15,
  );

  // Agregar equipo
  await service.agregarEquipo(grua);
  print('Equipo agregado: ${grua.nombre}');

  // Obtener todos los equipos
  final equipos = service.obtenerEquipos();
  print('Total de equipos: ${equipos.length}');

  // Iterar y mostrar
  for (var equipo in equipos) {
    print(
      '${equipo.nombre}: ${equipo.dias} días × \$${equipo.costoPorDia}/día = \$${equipo.total}',
    );
  }

  // Obtener equipo específico por ID
  final equipoBuscado = service.obtenerEquipoPorId(grua.id);
  if (equipoBuscado != null) {
    print('Equipo encontrado: ${equipoBuscado.nombre}');
  }

  // ==================== EDITAR EQUIPO ====================

  // Crear versión actualizada
  final gruaActualizada = Equipo(
    id: grua.id,
    nombre: 'Grúa Telescópica 50T',
    costoPorDia: 375.00, // Precio aumentado
    dias: 20, // Más días
  );

  // Actualizar
  await service.actualizarEquipo(gruaActualizada);
  print('Equipo actualizado');

  // ==================== CÁLCULOS ====================

  // Total general
  double totalGeneral = service.calcularTotalEquipos();
  print('Total general equipos: \$$totalGeneral');

  // Cantidad de equipos
  int cantidad = service.obtenerCantidadEquipos();
  print('Cantidad de equipos: $cantidad');

  // Promedio de costo por día
  double promedioCosto = service.calcularPromedioCostoDia();
  print('Costo promedio por día: \$$promedioCosto');

  // Promedio de días
  double promedioDias = service.calcularPromedioDias();
  print('Días promedio de renta: $promedioDias');

  // ==================== ELIMINACIÓN ====================

  // Eliminar un equipo
  await service.eliminarEquipo(grua.id);
  print('Equipo eliminado');

  // Limpiar todos
  await service.limpiarEquipos();
  print('Todos los equipos eliminados');
}

// ==================== EJEMPLO PRÁCTICO: PRESUPUESTO CON EQUIPOS ====================

Future<void> ejemploPresupuestoConEquipos() async {
  final service = EquiposService();
  await service.initialize();

  print('=== PRESUPUESTO DE CONSTRUCCIÓN CON EQUIPOS ===\n');

  // 1. Agregar varios equipos típicos
  final equiposAgregar = [
    Equipo(nombre: 'Grúa Telescópica 50T', costoPorDia: 350.00, dias: 20),
    Equipo(nombre: 'Excavadora CAT 320', costoPorDia: 280.00, dias: 15),
    Equipo(nombre: 'Compactadora Vibrante', costoPorDia: 120.00, dias: 10),
    Equipo(nombre: 'Andamios Metálicos', costoPorDia: 45.00, dias: 30),
    Equipo(nombre: 'Mezcladora de Concreto', costoPorDia: 25.00, dias: 45),
  ];

  for (var equipo in equiposAgregar) {
    await service.agregarEquipo(equipo);
  }

  print('Equipos agregados: ${equiposAgregar.length}\n');

  // 2. Mostrar listado detallado
  print('DETALLE DE EQUIPOS RENTADOS:');
  print('============================\n');

  final equipos = service.obtenerEquipos();
  for (var equipo in equipos) {
    final badge = equipo.costoPorDia > 200 ? '⭐ ' : '';
    print(
      '$badge${equipo.nombre}\n  '
      '${equipo.dias} días × \$${equipo.costoPorDia.toStringAsFixed(2)}/día = \$${equipo.total.toStringAsFixed(2)}\n',
    );
  }

  // 3. Cálculos y resumen
  final totalEquipos = service.calcularTotalEquipos();
  final cantidadEquipos = service.obtenerCantidadEquipos();
  final promedioCosto = service.calcularPromedioCostoDia();
  final promedioDias = service.calcularPromedioDias();

  print('\nRESUMEN FINANCIERO:');
  print('===================');
  print('Total equipos: $cantidadEquipos');
  print('Costo promedio por día: \$${promedioCosto.toStringAsFixed(2)}');
  print('Días promedio de renta: ${promedioDias.toStringAsFixed(1)}');
  print('TOTAL A PAGAR POR EQUIPOS: \$${totalEquipos.toStringAsFixed(2)}\n');

  // 4. Análisis de presupuesto total (incluyendo otros gastos)
  const totalMateriales = 15000.00;
  const totalManoObra = 25000.00;
  final totalPresupuesto = totalMateriales + totalManoObra + totalEquipos;

  print('PRESUPUESTO GENERAL DEL PROYECTO:');
  print('==================================');
  print('Materiales:     \$${totalMateriales.toStringAsFixed(2)}');
  print('Mano de Obra:   \$${totalManoObra.toStringAsFixed(2)}');
  print('Equipos:        \$${totalEquipos.toStringAsFixed(2)}');
  print('─' * 40);
  print('TOTAL:          \$${totalPresupuesto.toStringAsFixed(2)}');
  print(
    '\nPorcentaje de equipos: ${((totalEquipos / totalPresupuesto) * 100).toStringAsFixed(1)}%',
  );
}

// ==================== EJEMPLO: COMPARACIÓN DE OPCIONES ====================

Future<void> ejemploComparacionEquipos() async {
  final service = EquiposService();
  await service.initialize();

  print('=== COMPARACIÓN DE OPCIONES DE RENTA ===\n');

  // Tres opciones para excavar
  final opcion1 = Equipo(
    nombre: 'Excavadora CAT 320 (30 días)',
    costoPorDia: 280.00,
    dias: 30,
  );

  final opcion2 = Equipo(
    nombre: 'Excavadora CAT 315 (30 días)',
    costoPorDia: 240.00,
    dias: 30,
  );

  final opcion3 = Equipo(
    nombre: 'Excavadora Bobcat (30 días)',
    costoPorDia: 180.00,
    dias: 30,
  );

  print('Opción 1: CAT 320');
  print(
    '  ${opcion1.dias} días × \$${opcion1.costoPorDia}/día = \$${opcion1.total.toStringAsFixed(2)}\n',
  );

  print('Opción 2: CAT 315');
  print(
    '  ${opcion2.dias} días × \$${opcion2.costoPorDia}/día = \$${opcion2.total.toStringAsFixed(2)}\n',
  );

  print('Opción 3: Bobcat');
  print(
    '  ${opcion3.dias} días × \$${opcion3.costoPorDia}/día = \$${opcion3.total.toStringAsFixed(2)}\n',
  );

  final ahorro1 = opcion1.total - opcion3.total;
  final ahorro2 = opcion2.total - opcion3.total;

  print('ANÁLISIS:');
  print('Ahorro con CAT 315 vs CAT 320: \$${ahorro1.toStringAsFixed(2)}');
  print('Ahorro con Bobcat vs CAT 320: \$${ahorro2.toStringAsFixed(2)}');
  print(
    'Ahorro con Bobcat vs CAT 315: \$${(opcion2.total - opcion3.total).toStringAsFixed(2)}',
  );
  print(
    '\n⚠️ Nota: Considerar capacidad, condiciones del sitio y reputación del proveedor',
  );
}
