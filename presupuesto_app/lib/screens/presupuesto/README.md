# Pantalla de Resumen del Presupuesto

## Descripción General

La pantalla de resumen muestra un desglose completo de todos los componentes del presupuesto en 6 pasos:

1. **Información Básica** - Título, superficie, fecha, estado
2. **Mano de Obra** - Roles, personas, días y costos
3. **Materiales** - Catálogo de materiales con cantidades y precios
4. **Equipos** - Equipos rentados con días y costos por día
5. **Finanzas** - Cálculos de imprevistos, utilidad e IVA
6. **Resumen** - Vista completa con desglose visual

## Estructura de Archivos

```
lib/screens/presupuesto/
├── wizard_presupuesto_screen.dart    # Wizard principal (6 pasos)
├── resumen_presupuesto_screen.dart   # Pantalla standalone
├── widgets/
│   ├── seccion_materiales.dart
│   ├── seccion_mano_obra.dart
│   ├── seccion_equipos.dart
│   └── seccion_finanzas.dart
└── steps/
    ├── step_info.dart
    ├── step_mano_obra.dart
    ├── step_materiales.dart
    ├── step_equipos.dart
    ├── step_finanzas.dart
    └── step_resumen.dart
```

## Pantalla de Resumen - StepResumen

### Ubicación
`lib/screens/presupuesto/steps/step_resumen.dart`

### Características

✅ **Desglose Completo**
- Sección Materiales con lista y total
- Sección Mano de Obra con roles y costos
- Sección Equipos con días y costos
- Sección Finanzas con cálculos automáticos

✅ **Información Clara**
- Encabezado con título y fecha del presupuesto
- Cards organizadas por categoría
- Totales destacados para cada sección

✅ **Total Final Prominente**
- Caja especial verde con el **TOTAL FINAL**
- Incluye información sobre IVA y márgenes

## Widgets Auxiliares

### 1. SeccionMateriales
```dart
SeccionMateriales(
  materiales: List<MaterialPresupuesto>
)
```
Muestra:
- Lista de materiales con nombre, cantidad, precio unitario
- Total de materiales en color azul

### 2. SeccionManoObra
```dart
SeccionManoObra(
  manoObra: List<ManoObra>
)
```
Muestra:
- Lista con rol, cantidad de personas, días
- Cálculo automático del costo según tipo de pago
- Total en color púrpura

### 3. SeccionEquipos
```dart
SeccionEquipos(
  equipos: List<Equipo>
)
```
Muestra:
- Lista de equipos con nombre, días, costo por día
- Total en color naranja

### 4. SeccionFinanzas
```dart
SeccionFinanzas(
  totalMateriales: double,
  totalManoObra: double,
  totalEquipos: double,
  finanzas: Finanzas
)
```
Muestra:
- Costo directo (suma de todos)
- Imprevistos calculados
- Subtotal
- Utilidad calculada
- Precio final
- IVA (si aplica)

## ResumenPresupuestoScreen - Pantalla Standalone

### Ubicación
`lib/screens/presupuesto/resumen_presupuesto_screen.dart`

### Uso
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ResumenPresupuestoScreen(
      materiales: materiales,
      equipos: equipos,
      manoObra: manoObra,
      finanzas: finanzas,
      titulo: 'Casa 100m²',
      fecha: DateTime.now(),
    ),
  ),
);
```

### Parámetros
```dart
ResumenPresupuestoScreen(
  required List<MaterialPresupuesto> materiales,
  required List<Equipo> equipos,
  required List<ManoObra> manoObra,
  required Finanzas finanzas,
  required String? titulo,
  required DateTime? fecha,
)
```

### Características Adicionales
- Scaffold completo con AppBar
- Botones "Guardar" y "Exportar"
- Desglose de componentes en barras de progreso
- Muestra porcentaje de cada componente respecto al total

## Integración en el Wizard

### Paso 6: Resumen
En `wizard_presupuesto_screen.dart`, el último paso es:

```dart
Step(
  title: const Text('Resumen'),
  content: StepResumen(
    materiales: _materialesService.obtenerMaterialesPresupuesto(),
    equipos: _equiposService.obtenerEquipos(),
    manoObra: _manoObra != null ? [_manoObra!] : [],
    finanzas: _finanzas,
    titulo: _titulo.isNotEmpty ? _titulo : null,
    fecha: _fechaCreacion,
  ),
  isActive: _currentStep >= 5,
)
```

## Cálculos Automáticos

Todos los totales se calculan automáticamente:

### Totales por Sección
```
Total Materiales = Suma de (cantidad × precioUnitario)
Total Mano Obra = Suma de costos según tipo de pago
Total Equipos = Suma de (días × costoPorDía)
```

### Cálculos Financieros
```
Costo Directo = Materiales + ManoObra + Equipos
Imprevistos = Costo × (% imprevistos)
Subtotal = Costo + Imprevistos
Utilidad = Subtotal × (% utilidad)
Precio Final = Subtotal + Utilidad
IVA = Precio Final × 0.16 (si aplica)
TOTAL = Precio Final + IVA
```

## Gestión del Estado

El widget **no es Stateful**, todos los cálculos se realizan en `build()`:

```dart
// Los totales se recalculan en cada build
final totalMateriales = materiales.fold<double>(0, 
  (sum, m) => sum + m.total
);

// Se usa la CalculadoraFinanzas para todos los valores
final resultados = calculadora.calcularTodo(...);
```

## Flujo de Datos en el Wizard

```
Paso 1: Info
  ↓
Paso 2: Mano de Obra (_manoObra)
  ↓
Paso 3: Materiales (MaterialesService)
  ↓
Paso 4: Equipos (EquiposService)
  ↓
Paso 5: Finanzas (_finanzas)
  ↓
Paso 6: Resumen (todos los datos anteriores)
  ↓
Guardar: Crea Presupuesto en Hive
```

## Resolución del Error de setState

**Problema anterior:**
```
setState() or markNeedsBuild() called during build
```

**Solución aplicada:**
1. En `FinanzasScreen.initState()`: Usar `addPostFrameCallback()` para diferir `_calcularValores()`
2. En `_calcularValores()`: Usar `addPostFrameCallback()` para el callback `onFinanzasChanged()`

**Código:**
```dart
@override
void initState() {
  super.initState();
  
  // Diferir el cálculo hasta después de build
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _calcularValores();
  });
}

void _calcularValores() {
  setState(() {
    // Actualizar UI
  });
  
  // Notificar padres diferidamente
  WidgetsBinding.instance.addPostFrameCallback((_) {
    widget.onFinanzasChanged(finanzas);
  });
}
```

## Colores y Estilos

| Componente | Color | Uso |
|-----------|-------|-----|
| Materiales | Azul | Total y cards |
| Mano Obra | Púrpura | Total y cards |
| Equipos | Naranja | Total y cards |
| Imprevistos | Ámbar | Barra de progreso |
| Utilidad | Verde Azulado | Barra de progreso |
| IVA | Rojo | Barra de progreso |
| Total Final | Verde | Highlight principal |

## UI Components Utilizados

- ✅ `SingleChildScrollView` - Scroll vertical
- ✅ `Card` - Secciones principales
- ✅ `ListView.separated` - Listas de items
- ✅ `Divider` - Separadores visuales
- ✅ `ListTile` - Items de lista (en widgets separados)
- ✅ `LinearProgressIndicator` - Barras de progreso
- ✅ `Container` - Cajas de total destacadas
- ✅ `Row/Column` - Layouts

## Casos de Uso

### 1. Ver resumen durante el wizard
El usuario navega naturalmente al Paso 6 del wizard.

### 2. Abrir resumen en pantalla independiente
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ResumenPresupuestoScreen(
      materiales: presupuesto.materiales,
      equipos: presupuesto.equipos,
      manoObra: presupuesto.manoObra,
      finanzas: presupuesto.finanzas,
      titulo: presupuesto.titulo,
      fecha: presupuesto.fechaCreacion,
    ),
  ),
);
```

### 3. Exportar presupuesto
El botón "Exportar" puede:
- Generar PDF
- Enviar email
- Guardar en archivo

## Validación

✅ **Sin errores críticos** (162 warnings solamente, mismos que antes)
✅ **Compilación exitosa**
✅ **Integración completa en wizard**
✅ **Cálculos automáticos funcionales**
✅ **setState resuelto**

## Próximas Mejoras Sugeridas

- [ ] Exportar a PDF con diseño profesional
- [ ] Enviar presupuesto por email
- [ ] Guardar presupuestos en Hive
- [ ] Comparar múltiples presupuestos
- [ ] Historial de presupuestos
- [ ] Firmas digitales
- [ ] QR con enlace al presupuesto
