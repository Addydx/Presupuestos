import 'package:presupuesto_app/models/presupuesto/material_catalogo.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

class MaterialesSeed {
  /// Datos iniciales de materiales para el catálogo
  static final List<MaterialCatalogo> materialesIniciales = [
    // ==== ESTRUCTURAL ====
    MaterialCatalogo(
      nombre: 'Cemento Gris',
      categoria: 'Estructural',
      unidad: 'kg',
      precioReferencia: 0.15,
      tienda: 'Mejoramiento ABC',
    ),
    MaterialCatalogo(
      nombre: 'Arena Gruesa',
      categoria: 'Estructural',
      unidad: 'm³',
      precioReferencia: 45.00,
      tienda: 'Cantera Local',
    ),
    MaterialCatalogo(
      nombre: 'Grava',
      categoria: 'Estructural',
      unidad: 'm³',
      precioReferencia: 50.00,
      tienda: 'Cantera Local',
    ),
    MaterialCatalogo(
      nombre: 'Ladrillo Común',
      categoria: 'Estructural',
      unidad: 'pieza',
      precioReferencia: 0.35,
      tienda: 'Ladrillería El Centro',
    ),
    MaterialCatalogo(
      nombre: 'Varilla de Acero #4',
      categoria: 'Estructural',
      unidad: 'kg',
      precioReferencia: 3.50,
      tienda: 'Acería del Sur',
    ),

    // ==== ACABADOS ====
    MaterialCatalogo(
      nombre: 'Yeso en Polvo',
      categoria: 'Acabados',
      unidad: 'kg',
      precioReferencia: 0.50,
      tienda: 'Mejoramiento ABC',
    ),
    MaterialCatalogo(
      nombre: 'Baldosa Cerámica 30x30',
      categoria: 'Acabados',
      unidad: 'm²',
      precioReferencia: 15.00,
      tienda: 'Cerámica Premium',
    ),
    MaterialCatalogo(
      nombre: 'Porcelanato 60x60',
      categoria: 'Acabados',
      unidad: 'm²',
      precioReferencia: 35.00,
      tienda: 'Cerámica Premium',
    ),
    MaterialCatalogo(
      nombre: 'Moldura de Poliestireno',
      categoria: 'Acabados',
      unidad: 'metro',
      precioReferencia: 2.50,
      tienda: 'Materiales de Construcción XYZ',
    ),

    // ==== PINTURA ====
    MaterialCatalogo(
      nombre: 'Pintura Acrílica Blanca',
      categoria: 'Pintura',
      unidad: 'litro',
      precioReferencia: 8.00,
      tienda: 'Pinturas Magno',
    ),
    MaterialCatalogo(
      nombre: 'Pintura al Óleo',
      categoria: 'Pintura',
      unidad: 'litro',
      precioReferencia: 12.00,
      tienda: 'Pinturas Magno',
    ),
    MaterialCatalogo(
      nombre: 'Primer Selador',
      categoria: 'Pintura',
      unidad: 'litro',
      precioReferencia: 6.50,
      tienda: 'Pinturas Magno',
    ),

    // ==== TUBERÍAS Y ACCESORIOS ====
    MaterialCatalogo(
      nombre: 'Tubo PVC 1/2"',
      categoria: 'Tuberías',
      unidad: 'metro',
      precioReferencia: 1.20,
      tienda: 'Distribuidora Hidráulica',
    ),
    MaterialCatalogo(
      nombre: 'Tubo PVC 3/4"',
      categoria: 'Tuberías',
      unidad: 'metro',
      precioReferencia: 2.00,
      tienda: 'Distribuidora Hidráulica',
    ),
    MaterialCatalogo(
      nombre: 'Codos PVC 1/2"',
      categoria: 'Tuberías',
      unidad: 'pieza',
      precioReferencia: 0.45,
      tienda: 'Distribuidora Hidráulica',
    ),

    // ==== HERRAJES ====
    MaterialCatalogo(
      nombre: 'Clavo 2"',
      categoria: 'Herrajes',
      unidad: 'kg',
      precioReferencia: 2.50,
      tienda: 'Ferretería Don Juan',
    ),
    MaterialCatalogo(
      nombre: 'Tornillo 1"',
      categoria: 'Herrajes',
      unidad: 'caja (50 piezas)',
      precioReferencia: 3.00,
      tienda: 'Ferretería Don Juan',
    ),
    MaterialCatalogo(
      nombre: 'Pernos de Anclaje',
      categoria: 'Herrajes',
      unidad: 'pieza',
      precioReferencia: 5.00,
      tienda: 'Ferretería Don Juan',
    ),
  ];

  /// Cargar datos iniciales en el catálogo (ejecutar una sola vez)
  static Future<void> inicializarCatalogo(MaterialesService service) async {
    final catalogoActual = service.obtenerCatalogos();

    // Si el catálogo ya existe, no agregar duplicados
    if (catalogoActual.isNotEmpty) {
      print('Catálogo ya inicializado con ${catalogoActual.length} materiales');
      return;
    }

    print(
      'Inicializando catálogo con ${materialesIniciales.length} materiales...',
    );
    for (var material in materialesIniciales) {
      await service.agregarAlCatalogo(material);
    }
    print('Catálogo inicializado correctamente');
  }
}
