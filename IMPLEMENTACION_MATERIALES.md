# GUÍA DE IMPLEMENTACIÓN - MÓDULO DE MATERIALES

## Paso 1: Registrar Adaptadores Hive

En tu `main.dart`, agrega lo siguiente antes de `runApp()`:

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/material_catalogo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Registrar adaptadores (IMPORTANTE)
  Hive.registerAdapter(MaterialPresupuestoAdapter());
  Hive.registerAdapter(MaterialCatalogoAdapter());
  
  runApp(const MyApp());
}
```

## Paso 2: Generar Archivos .g.dart

Cuando registres los adaptadores con Hive, necesitas generar los archivos `.g.dart`.

Ejecuta:
```bash
flutter pub run build_runner build
```

O si hay conflictos:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Esto generará:
- `material.g.dart`
- `material_catalogo.g.dart`

## Paso 3: Inicializar Catálogo (Opcional)

Si deseas poblar el catálogo con datos iniciales:

```dart
import 'package:presupuesto_app/services/materiales_service.dart';
import 'package:presupuesto_app/services/materiales_seed.dart';

void main() async {
  // ... código previo ...
  
  // Inicializar catálogo con datos de prueba
  final materialesService = MaterialesService();
  await materialesService.initialize();
  await MaterialesSeed.inicializarCatalogo(materialesService);
  
  runApp(const MyApp());
}
```

## Paso 4: Integrar en Widget Tree

El módulo de materiales ya está integrado en el Wizard. Si usas en otro lugar:

```dart
import 'package:presupuesto_app/screens/materiales/materiales_presupuesto_screen.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

// En tu pantalla/widget
final materialesService = MaterialesService();

MaterialesPresupuestoScreen(
  materialesService: materialesService,
)
```

## Paso 5: Asegurar que Material es MaterialPresupuesto

En `lib/models/presupuesto/presupuesto.dart`, verifica que importes:

```dart
import 'material.dart'; // No uses "Material" como alias
```

Y que el campo sea:
```dart
@HiveField(9)
List<Material> materiales; // Esta es MaterialPresupuesto
```

---

## ERRORES COMUNES Y SOLUCIONES

### Error: "ManoObra is a subtype of invalid type"
**Causa**: Adaptadores no registrados en Hive
**Solución**: Ejecuta `flutter pub run build_runner build`

### Error: "Box not found: materiales_catalogo"
**Causa**: El servicio no fue inicializado
**Solución**: Llama `await materialesService.initialize()` antes de usarlo

### Error: "type 'Material' is not a subtype of type 'MaterialPresupuesto'"
**Causa**: Inconsistencia en las importaciones
**Solución**: Verifica que presupuesto.dart importe correctamente `material.dart` (que es MaterialPresupuesto)

### Error: "No adapter for..."
**Causa**: Adaptador no registrado antes de openBox
**Solución**: Registra el adaptador en main.dart ANTES de cualquier openBox

---

## FLUJO INTEGRIDAD DE DATOS

```
1. Usuario agrega material desde catálogo
   ↓
2. MaterialesService.agregarMaterialPresupuesto()
   ↓
3. Se guarda en Box "materiales_presupuesto"
   ↓
4. MaterialPresupuesto se agrega al Presupuesto cuando guarda
   ↓
5. El presupuesto completo se guarda en Hive (con materiales incluidos)
```

---

## TESTING RECOMENDADO

### Prueba manual 1: Agregar desde catálogo
1. Abre el Wizard de Presupuestos
2. Pasa a paso "Materiales"
3. Presiona botón "Catálogo"
4. Busca un material
5. Presiona "Agregar"
6. Completa cantidad y precio
7. Presiona "Guardar"
8. Verifica que aparezca en la lista

### Prueba manual 2: Crear personalizado
1. En paso "Materiales"
2. Presiona "Agregar Material"
3. Completa nombre, categoría, unidad, cantidad, precio
4. Presiona "Guardar"
5. Verifica que aparezca el badge "Personalizado"

### Prueba manual 3: Editar material
1. En lista de materiales
2. Abre menú de un material
3. Selecciona "Editar"
4. Cambia cantidad o precio
5. Presiona "Actualizar"
6. Verifica que el total se actualice

### Prueba manual 4: Eliminar material
1. En lista de materiales
2. Abre menú
3. Selecciona "Eliminar"
4. Confirma
5. Verifica eliminación

### Prueba manual 5: Búsqueda en catálogo
1. Abre catálogo
2. Escribe en el buscador
3. Filtra por categoría
4. Verifica que funcione

---

## MÉTRICAS DE ÉXITO

✅ Catálogo tiene 18+ materiales iniciales
✅ Búsqueda filtra por nombre y categoría
✅ Agregar material actualiza lista en tiempo real
✅ Total general se calcula correctamente
✅ Edición persiste en Hive
✅ Eliminación remueve de la lista
✅ Materiales personalizados marcan con badge
✅ Presupuesto incluye materiales al guardar

---

## PRÓXIMOS PASOS

1. **Mejorar UX**: Agregar imágenes de materiales
2. **Búsqueda avanzada**: Filtros por precio, stock, proveedor
3. **Sincronización**: Conectar con API de precios online
4. **Reportes**: Exportar lista de materiales a PDF
5. **Descuentos**: Agregar descuentos por cantidad
6. **Historial**: Guardar histórico de precios por material
7. **Favoritos**: Marcar materiales más usados

---

## SOPORTE

Para problemas, verifica:
1. `lib/screens/materiales/README.md` - Documentación técnica
2. `MaterialesService` - Lógica completa
3. Archivos `.g.dart` - Generados correctamente por Hive
