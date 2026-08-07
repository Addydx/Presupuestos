# Módulo de Materiales - Documentación

## Resumen
Arquitectura completa para gestionar materiales en presupuestos de construcción. Implementa catálogos reutilizables y materiales personalizados con persistencia en Hive.

Desde 2026-08-07 la captura de materiales dentro del presupuesto sigue el
flujo de **"una pregunta por pantalla"** del wizard (ver
`lib/screens/presupuesto/README.md`). La gestión del catálogo (búsqueda,
alta/edición de materiales de catálogo) sigue siendo un formulario
tradicional, sin cambios.

---

## 1. ESTRUCTURA DE CARPETAS

```
lib/
├── models/
│   └── presupuesto/
│       ├── material.dart              # MaterialPresupuesto (usado en presupuestos)
│       ├── material.g.dart            # Generado por Hive
│       ├── material_catalogo.dart     # MaterialCatalogo (catálogo base)
│       └── material_catalogo.g.dart   # Generado por Hive
├── services/
│   └── materiales_service.dart        # Servicio con toda la lógica
├── screens/
│   ├── presupuesto/
│   │   └── wizard/
│   │       └── agregar_material_screen.dart   # Mini-flujo de 3 preguntas para agregar/editar
│   └── materiales/
│       ├── catalogo_materiales_screen.dart       # Catálogo con búsqueda
│       └── agregar_editar_material_screen.dart   # Alta/edición de materiales de catálogo
```

---

## 2. MODELOS HIVE

### MaterialCatalogo (typeId: 7)
Material base disponible para reutilizar:
- `id`: Identificador único
- `nombre`: Nombre del material
- `categoria`: Categoría (Estructural, Acabados, etc.)
- `unidad`: Unidad de medida (kg, litro, m², pieza)
- `precioReferencia`: Precio de referencia
- `imagen`: URL de imagen (opcional)
- `tienda`: Tienda o proveedor (opcional)
- `fechaCreacion`: Timestamp

### MaterialPresupuesto (typeId: 0)
Material utilizado en un presupuesto específico:
- `id`: ID único
- `nombre`: Nombre del material
- `categoria`: Categoría (los materiales agregados a mano dentro del wizard
  se guardan con categoría `"General"`; los que vienen del catálogo heredan
  la categoría del catálogo)
- `unidad`: Unidad de medida
- `cantidad`: Cantidad usada
- `precioUnitario`: Precio pagado
- `esPersonalizado`: Booleano (true si no está en catálogo)
- `materialCatalogoId`: Referencia al catálogo (opcional)
- `total` (getter): Calcula cantidad × precioUnitario

---

## 3. SERVICIO: MaterialesService

### Métodos principales

#### Catálogo
```dart
obtenerCatalogos()              // List<MaterialCatalogo>
obtenerPorCategoria(String)     // List<MaterialCatalogo>
buscar(String termo)            // List<MaterialCatalogo>
agregarAlCatalogo()
actualizarCatalogo()
eliminarDelCatalogo()
obtenerCategorias()             // Set<String>
```

#### Materiales del Presupuesto
```dart
agregarMaterialPresupuesto()
actualizarMaterialPresupuesto()
obtenerMaterialesPresupuesto()  // List<MaterialPresupuesto>
eliminarMaterialPresupuesto()
limpiarMaterialesPresupuesto()
```

#### Cálculos
```dart
calcularTotalMateriales()       // double
calcularSubtotalPorCategoria()  // Map<String, double>
obtenerCantidadMateriales()     // int
```

---

## 4. PANTALLAS

### Pregunta "¿Qué materiales vas a usar?" (dentro del wizard)
**Ubicación**: `_pasoMateriales()` en `lib/screens/presupuesto/wizard_presupuesto_screen.dart`

**Propósito**: Listar y gestionar los materiales ya agregados al presupuesto que se está capturando.

**Características**:
- Tarjetas grandes con nombre, cantidad × unidad × precio, y total
- Botón "Agregar material" (abre `AgregarMaterialScreen`)
- Botón "Catálogo" (abre `CatalogoMaterialesScreen`)
- Editar/eliminar por tarjeta (con confirmación al eliminar)
- Estado vacío: "Todavía no agregas materiales. Toca el botón para agregar el primero."
- Siempre se puede tocar "Siguiente" sin agregar nada

---

### AgregarMaterialScreen (mini-flujo de una pregunta por pantalla)
**Ubicación**: `lib/screens/presupuesto/wizard/agregar_material_screen.dart`

**Propósito**: Capturar o editar un material, una pregunta a la vez.

**Pasos**:
1. ¿Qué material vas a agregar? (se salta si el material viene del catálogo, que ya trae nombre fijo)
2. ¿Cuánto vas a necesitar? — cantidad + unidad (chips: pieza, kg, bulto, litro, m, m², m³, Otro)
3. ¿Cuánto cuesta cada unidad?

**Cálculos automáticos**:
- Total = Cantidad × Precio Unitario (mostrado en vivo en el paso 3)

**Validaciones**:
- Nombre requerido (si no viene del catálogo)
- Cantidad: número mayor a cero + unidad elegida
- Precio: número mayor a cero
- Aviso no bloqueante si el precio parece un error de dedo (`AdvertenciaMontoAlto`)

Al terminar (`Navigator.pop` con el `MaterialPresupuesto` resultante), quien
llamó a la pantalla (`_abrirAgregarMaterial`/`_abrirEditarMaterial` en el
wizard) es responsable de guardarlo con `MaterialesService`.

---

### CatalogoMaterialesScreen
**Propósito**: Buscar y seleccionar materiales del catálogo

**Características**:
- Buscador en tiempo real
- Filtro por categoría (chips)
- Lista de materiales del catálogo
- Botón "Agregar" por material
- Información: nombre, categoría, precio referencia
- Empty state cuando no hay resultados

**Flujo**:
1. Usuario busca/filtra
2. Selecciona material
3. Se abre `AgregarEditarMaterialScreen` con datos del catálogo
4. Usuario completa cantidad y precio
5. Se agrega al presupuesto

---

### AgregarEditarMaterialScreen
**Propósito**: Capturar datos de un material de catálogo (nombre/categoría/unidad fijos, cantidad y precio editables). Es un formulario tradicional (varios campos por pantalla), no sigue el patrón de una pregunta por pantalla — se usa únicamente desde el flujo de `CatalogoMaterialesScreen`.

**Campos**:
- Nombre (read-only, viene del catálogo)
- Categoría (read-only, viene del catálogo)
- Unidad (read-only, viene del catálogo)
- Cantidad (editable, decimal)
- Precio Unitario (editable, decimal)

**Cálculos automáticos**:
- Total = Cantidad × Precio Unitario (actualización en tiempo real)

**Validaciones**:
- Cantidad: requerido, número válido, > 0
- Precio: requerido, número válido, > 0

**Botones**:
- Cancelar: Vuelve atrás
- Guardar/Actualizar: Guarda en Hive y retorna MaterialPresupuesto

---

## 5. INTEGRACIÓN EN EL WIZARD

El paso "Materiales" es uno más de la lista dinámica de preguntas que arma
`_pasos` en `wizard_presupuesto_screen.dart`. No hay un `Stepper` ni pasos
numerados fijos: el wizard avanza pantalla por pantalla y el usuario puede
volver a "Materiales" en cualquier momento desde la pantalla de resumen
final (tocando el renglón "Materiales").

```dart
// Dentro de _pasoMateriales() en wizard_presupuesto_screen.dart
Future<void> _abrirAgregarMaterial() async {
  final resultado = await Navigator.push<MaterialPresupuesto>(
    context,
    MaterialPageRoute(builder: (context) => const AgregarMaterialScreen()),
  );
  if (resultado == null) return;
  await _materialesService.agregarMaterialPresupuesto(resultado);
  if (!mounted) return;
  setState(() {});
  _programarAutoguardado();
}
```

---

## 6. FLUJO DE USUARIO

### Caso 1: Agregar material del catálogo
1. Usuario en la pantalla "¿Qué materiales vas a usar?"
2. Presiona "Catálogo"
3. `CatalogoMaterialesScreen` se abre
4. Busca/filtra material
5. Presiona "Agregar"
6. `AgregarEditarMaterialScreen` se abre con datos del catálogo (nombre, categoría, unidad, precio ref)
7. Usuario ajusta cantidad y precio
8. Presiona "Guardar"
9. `MaterialPresupuesto` se agrega a Hive
10. Vuelve a la pantalla de lista de materiales, actualizada

### Caso 2: Crear material personalizado
1. Usuario en "¿Qué materiales vas a usar?"
2. Presiona "Agregar material"
3. `AgregarMaterialScreen` se abre en la pregunta 1 de 3 ("¿Qué material vas a agregar?")
4. Usuario responde nombre → cantidad + unidad → precio, una pantalla a la vez
5. Presiona "Guardar material" en el último paso
6. `MaterialPresupuesto` se agrega con `esPersonalizado = true`

### Caso 3: Editar material
1. Usuario en la lista de materiales del wizard
2. Toca el ícono de editar en la tarjeta
3. `AgregarMaterialScreen` se abre precargada con los datos existentes
4. Usuario modifica cantidad/precio (o nombre/unidad si no viene del catálogo)
5. Presiona "Guardar material"
6. `MaterialPresupuesto` se actualiza en Hive

### Caso 4: Eliminar material
1. Usuario en la lista
2. Toca el ícono de eliminar en la tarjeta
3. Diálogo de confirmación
4. Se elimina de Hive
5. Lista se actualiza

---

## 7. CÁLCULOS IMPLEMENTADOS

### Por Material
```dart
total = cantidad × precioUnitario
```

### Por Presupuesto
```dart
totalGeneral = Σ(material.total) para todos los materiales
```

### Por Categoría
```dart
subtotalCategoria = Σ(material.total) por categoría
```

---

## 8. PERSISTENCIA CON HIVE

### Boxes
- **materiales_catalogo**: Almacena MaterialCatalogo
- **materiales_presupuesto**: Almacena MaterialPresupuesto

### Inicialización
```dart
final service = MaterialesService();
await service.initialize(); // Abre las boxes de Hive
```

---

## 9. VALIDACIONES

### Nivel de Campo
- Nombre: requerido, no vacío (solo si el material no viene del catálogo)
- Cantidad: requerido, número válido, > 0, unidad elegida
- Precio: requerido, número válido, > 0

### Nivel de Lógica
- MaterialCatalogo requiere nombre, categoría, unidad, precio
- MaterialPresupuesto requiere nombre, categoría, unidad, cantidad, precio

---

## 10. EJEMPLOS DE USO

### Inicializar en main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MaterialCatalogoAdapter());
  Hive.registerAdapter(MaterialPresupuestoAdapter());

  runApp(const MyApp());
}
```

### Acceder a materiales del presupuesto
```dart
final service = MaterialesService();
await service.initialize();

final materiales = service.obtenerMaterialesPresupuesto();
final total = service.calcularTotalMateriales();
final subtotales = service.calcularSubtotalPorCategoria();
```

---

## 11. VENTAJAS DE LA ARQUITECTURA

✅ **Separación clara**: Modelos, servicio, pantallas independientes
✅ **Reutilizable**: MaterialCatalogo se puede usar en múltiples presupuestos
✅ **Escalable**: Fácil agregar búsqueda avanzada, filtros, etc.
✅ **Testeable**: Servicio sin dependencias UI
✅ **Persistente**: Todo se guarda en Hive automáticamente
✅ **Cálculos automáticos**: Totales y subtotales en tiempo real
✅ **Validaciones robustas**: A nivel campo y lógica
✅ **UX simple**: una pregunta por pantalla al capturar, sin formularios largos

---

## 12. PRÓXIMAS MEJORAS

- [ ] Imágenes de materiales
- [ ] Integración con proveedores online
- [ ] Histórico de precios
- [ ] Exportar presupuesto a PDF
- [ ] Comparar precios entre proveedores
- [ ] Materiales más usados (frecuencia)
- [ ] Descuentos por cantidad
- [ ] Sincronización en la nube
