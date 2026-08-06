# Módulo de Materiales - Documentación

## Resumen
Arquitectura completa para gestionar materiales en presupuestos de construcción. Implementa catálogos reutilizables y materiales personalizados con persistencia en Hive.

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
│   │   └── steps/
│   │       └── step_materiales.dart   # Step para integrar en Wizard
│   └── materiales/
│       ├── materiales_presupuesto_screen.dart    # Lista de materiales
│       ├── catalogo_materiales_screen.dart       # Catálogo con búsqueda
│       └── agregar_editar_material_screen.dart   # Agregar/editar/personalizado
```

---

## 2. MODELOS HIVE

### MaterialCatalogo (typeId: 5)
Material base disponible para reutilizar:
- `id`: Identificador único
- `nombre`: Nombre del material
- `categoria`: Categoría (Estructural, Acabados, etc.)
- `unidad`: Unidad de medida (kg, litro, m², pieza)
- `precioReferencia`: Precio de referencia
- `imagen`: URL de imagen (opcional)
- `tienda`: Tienda o proveedor (opcional)
- `fechaCreacion`: Timestamp

### MaterialPresupuesto (typeId: 4)
Material utilizado en un presupuesto específico:
- `id`: ID único
- `nombre`: Nombre del material
- `categoria`: Categoría
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

### MaterialesPresupuestoScreen
**Propósito**: Listar y gestionar materiales del presupuesto

**Características**:
- Lista de materiales con scroll
- Botón flotante "Agregar Material"
- Botón "Catálogo" para seleccionar del catálogo
- Eliminar material (con confirmación)
- Editar material
- Total general calculado automáticamente
- Estado vacío (empty state)

**Acciones**:
- Agregar: Abre `AgregarEditarMaterialScreen`
- Catálogo: Abre `CatalogoMaterialesScreen`
- Editar: Abre `AgregarEditarMaterialScreen` con datos
- Eliminar: Elimina de Hive

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
**Propósito**: Capturar datos de materiales (nuevo, edición o desde catálogo)

**Campos**:
- Nombre (read-only si viene del catálogo)
- Categoría (read-only si viene del catálogo)
- Unidad (read-only si viene del catálogo)
- Cantidad (editable, decimal)
- Precio Unitario (editable, decimal)
- Checkbox "Material Personalizado"

**Cálculos automáticos**:
- Total = Cantidad × Precio Unitario (actualización en tiempo real)

**Validaciones**:
- Campo requerido: nombre, categoría, unidad, cantidad, precio
- Número válido: cantidad, precio
- Número positivo (implícito)

**Botones**:
- Cancelar: Vuelve atrás
- Guardar/Actualizar: Guarda en Hive y retorna MaterialPresupuesto

---

## 5. INTEGRACIÓN EN WIZARD

### StepMateriales
Wrapper que envuelve `MaterialesPresupuestoScreen` para integración en el Stepper.

```dart
Step(
  title: const Text('Materiales'),
  content: StepMateriales(
    materialesService: MaterialesService(),
  ),
  isActive: _currentStep >= 2,
),
```

---

## 6. FLUJO DE USUARIO

### Caso 1: Agregar material del catálogo
1. Usuario en paso "Materiales" del Wizard
2. Presiona "Catálogo"
3. CatalogoMaterialesScreen se abre
4. Busca/filtra material
5. Presiona "Agregar"
6. AgregarEditarMaterialScreen se abre con datos del catálogo (nombre, categoría, unidad, precio ref)
7. Usuario ajusta cantidad y precio
8. Presiona "Guardar"
9. MaterialPresupuesto se agrega a Hive
10. Vuelve a MaterialesPresupuestoScreen actualizada

### Caso 2: Crear material personalizado
1. Usuario en paso "Materiales"
2. Presiona "Agregar Material"
3. AgregarEditarMaterialScreen se abre vacío
4. Usuario completa: nombre, categoría, unidad, cantidad, precio
5. Checkbox "Material Personalizado" está marcado automáticamente
6. Presiona "Guardar"
7. MaterialPresupuesto se agrega con `esPersonalizado = true`

### Caso 3: Editar material
1. Usuario en lista de materiales
2. Presiona menú (three dots) en material
3. Selecciona "Editar"
4. AgregarEditarMaterialScreen se abre con datos
5. Usuario modifica cantidad/precio
6. Presiona "Actualizar"
7. MaterialPresupuesto se actualiza en Hive

### Caso 4: Eliminar material
1. Usuario en lista
2. Presiona menú en material
3. Selecciona "Eliminar"
4. Diálogo de confirmación
5. Se elimina de Hive
6. Lista se actualiza

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
- Nombre: requerido, no vacío
- Categoría: requerido, no vacío
- Unidad: requerido, no vacío
- Cantidad: requerido, número válido, > 0
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

### Usar en Wizard
```dart
Step(
  title: const Text('Materiales'),
  content: StepMateriales(
    materialesService: MaterialesService(),
  ),
  isActive: _currentStep >= 2,
),
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
✅ **UX limpia**: Estado vacío, diálogos de confirmación, feedback visual

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
