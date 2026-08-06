// EJEMPLOS DE USO - SERVICIO DE MATERIALES

import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/material_catalogo.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

void ejemplosUso() async {
  // ==================== INICIALIZACIÓN ====================

  final service = MaterialesService();
  await service.initialize(); // IMPORTANTE: Llamar primero

  // ==================== CATÁLOGO ====================

  // Obtener todos los materiales del catálogo
  final todos = service.obtenerCatalogos();
  print('Total de materiales en catálogo: ${todos.length}');

  // Buscar materiales
  final resultados = service.buscar('cemento');
  print('Materiales encontrados: $resultados');

  // Obtener por categoría
  final estructural = service.obtenerPorCategoria('Estructural');
  print('Materiales estructurales: $estructural');

  // Obtener categorías disponibles
  final categorias = service.obtenerCategorias();
  print('Categorías: $categorias');

  // Obtener un material específico del catálogo
  final material = service.obtenerCatalogoPorId('id_del_material');
  if (material != null) {
    print('Material encontrado: ${material.nombre}');
  }

  // ==================== AGREGAR AL CATÁLOGO ====================

  final nuevoMaterial = MaterialCatalogo(
    nombre: 'Madera de Pino',
    categoria: 'Carpintería',
    unidad: 'm³',
    precioReferencia: 200.00,
    tienda: 'Maderera Los Andes',
  );

  await service.agregarAlCatalogo(nuevoMaterial);
  print('Material agregado al catálogo');

  // ==================== PRESUPUESTO ====================

  // Crear un material del presupuesto
  final materialPresupuesto = MaterialPresupuesto(
    nombre: 'Cemento Gris',
    categoria: 'Estructural',
    unidad: 'kg',
    cantidad: 500,
    precioUnitario: 0.15,
    esPersonalizado: false,
  );

  // Agregar al presupuesto actual
  await service.agregarMaterialPresupuesto(materialPresupuesto);
  print('Material agregado al presupuesto');

  // Obtener todos los materiales del presupuesto
  final materiales = service.obtenerMaterialesPresupuesto();
  print('Materiales en presupuesto: ${materiales.length}');

  // Iterar y mostrar
  for (var mat in materiales) {
    print(
      '${mat.nombre}: ${mat.cantidad} ${mat.unidad} x \$${mat.precioUnitario} = \$${mat.total}',
    );
  }

  // ==================== CÁLCULOS ====================

  // Total general
  double totalGeneral = service.calcularTotalMateriales();
  print('Total de materiales: \$$totalGeneral');

  // Subtotal por categoría
  Map<String, double> subtotales = service.calcularSubtotalPorCategoria();
  subtotales.forEach((categoria, total) {
    print('$categoria: \$$total');
  });

  // Cantidad de materiales
  int cantidad = service.obtenerCantidadMateriales();
  print('Total de items: $cantidad');

  // ==================== EDICIÓN ====================

  // Obtener material a editar
  final materialsAEditar = service.obtenerMaterialPresupuestoPorId(
    'id_del_material',
  );

  if (materialsAEditar != null) {
    // Crear copia actualizada
    final actualizado = MaterialPresupuesto(
      id: materialsAEditar.id,
      nombre: materialsAEditar.nombre,
      categoria: materialsAEditar.categoria,
      unidad: materialsAEditar.unidad,
      cantidad: 600, // Cantidad actualizada
      precioUnitario: 0.16, // Precio actualizado
      esPersonalizado: materialsAEditar.esPersonalizado,
    );

    // Guardar actualización
    await service.actualizarMaterialPresupuesto(actualizado);
    print('Material actualizado');
  }

  // ==================== ELIMINACIÓN ====================

  // Eliminar un material específico
  await service.eliminarMaterialPresupuesto('id_del_material');
  print('Material eliminado');

  // Limpiar todos los materiales del presupuesto
  await service.limpiarMaterialesPresupuesto();
  print('Presupuesto limpiado');
}

// ==================== EJEMPLO PRÁCTICO: CASO DE USO ====================

Future<void> ejemploPresupuestoCompleto() async {
  final service = MaterialesService();
  await service.initialize();

  print('=== CREAR PRESUPUESTO CON MATERIALES ===\n');

  // 1. Agregar material desde catálogo
  final cementoDeCatalogo = service.obtenerCatalogoPorId('cemento_gris');
  if (cementoDeCatalogo != null) {
    final ceiento = MaterialPresupuesto(
      nombre: cementoDeCatalogo.nombre,
      categoria: cementoDeCatalogo.categoria,
      unidad: cementoDeCatalogo.unidad,
      cantidad: 1000, // Cantidad específica del presupuesto
      precioUnitario: 0.15, // Precio que conseguimos
      materialCatalogoId: cementoDeCatalogo.id,
    );
    await service.agregarMaterialPresupuesto(ceiento);
  }

  // 2. Agregar material personalizado
  final madera = MaterialPresupuesto(
    nombre: 'Cuartones 2x3',
    categoria: 'Carpintería',
    unidad: 'pieza',
    cantidad: 50,
    precioUnitario: 8.50,
    esPersonalizado: true,
  );
  await service.agregarMaterialPresupuesto(madera);

  // 3. Calcular totales
  final totalMateriales = service.calcularTotalMateriales();
  final subtotales = service.calcularSubtotalPorCategoria();

  print('RESUMEN DEL PRESUPUESTO:');
  print('========================\n');

  subtotales.forEach((categoria, total) {
    print('$categoria: \$${total.toStringAsFixed(2)}');
  });

  print('\nTotal de Materiales: \$${totalMateriales.toStringAsFixed(2)}\n');

  // 4. Listar detalles
  print('DETALLE DE MATERIALES:');
  print('======================\n');

  final materiales = service.obtenerMaterialesPresupuesto();
  for (var mat in materiales) {
    final badge = mat.esPersonalizado ? ' [PERSONALIZADO]' : '';
    print('${mat.nombre}$badge');
    print(
      '  ${mat.cantidad} ${mat.unidad} x \$${mat.precioUnitario.toStringAsFixed(2)} = \$${mat.total.toStringAsFixed(2)}',
    );
    print('');
  }
}

// ==================== EJEMPLO: BÚSQUEDA AVANZADA ====================

Future<void> ejemploBusquedaAvanzada() async {
  final service = MaterialesService();
  await service.initialize();

  print('=== BUSQUEDA Y FILTRADO ===\n');

  // Buscar por término
  final resultados = service.buscar('arena');
  print('Resultados de búsqueda "arena": ${resultados.length}');
  for (var mat in resultados) {
    print('  - ${mat.nombre} (\$${mat.precioReferencia})');
  }

  // Filtrar por categoría
  print('\nMateriales de Acabados:');
  final acabados = service.obtenerPorCategoria('Acabados');
  for (var mat in acabados) {
    print('  - ${mat.nombre} (\$${mat.precioReferencia} por ${mat.unidad})');
  }

  // Combinar búsqueda y filtro manualmente
  print('\nBúsqueda "tubo" EN categoría "Tuberías":');
  final todosEnCategoria = service.obtenerPorCategoria('Tuberías');
  final filtrados =
      todosEnCategoria
          .where((m) => m.nombre.toLowerCase().contains('tubo'))
          .toList();

  for (var mat in filtrados) {
    print('  - ${mat.nombre} (\$${mat.precioReferencia})');
  }
}

// ==================== EJEMPLO: REPORTES ====================

Future<void> ejemploReportes() async {
  final service = MaterialesService();
  await service.initialize();

  print('=== REPORTES ==\n');

  final materiales = service.obtenerMaterialesPresupuesto();
  final subtotales = service.calcularSubtotalPorCategoria();
  final total = service.calcularTotalMateriales();

  // Cantidad de materiales por categoría
  print('CANTIDAD POR CATEGORÍA:');
  for (var mat in materiales) {
    final cantidad =
        materiales.where((m) => m.categoria == mat.categoria).length;
    print('${mat.categoria}: $cantidad materiales');
  }

  // Material más caro
  if (materiales.isNotEmpty) {
    final masC = materiales.reduce(
      (current, next) => current.total > next.total ? current : next,
    );
    print(
      '\nMaterial más caro: ${masC.nombre} (\$${masC.total.toStringAsFixed(2)})',
    );
  }

  // Material más barato
  if (materiales.isNotEmpty) {
    final masB = materiales.reduce(
      (current, next) => current.total < next.total ? current : next,
    );
    print(
      'Material más barato: ${masB.nombre} (\$${masB.total.toStringAsFixed(2)})',
    );
  }

  // Promedio
  if (materiales.isNotEmpty) {
    final promedio = total / materiales.length;
    print('Precio promedio por material: \$${promedio.toStringAsFixed(2)}');
  }
}
