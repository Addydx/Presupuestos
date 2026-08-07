# Módulo de Equipos Rentados - Presupuesto App

## Descripción

Módulo completo para gestionar equipos rentados en presupuestos de construcción. Permite agregar, editar, eliminar y calcular automáticamente los costos de equipos rentados.

## Estructura

```
lib/
├── models/
│   └── presupuesto/
│       └── equipo.dart              # Modelo Equipo con Hive
├── services/
│   └── equipos_service.dart         # Singleton service para CRUD y cálculos
├── screens/
│   ├── equipos/
│   │   └── equipo_form_sheet.dart   # Bottom sheet add/edit
│   └── presupuesto/steps/
│       └── step_equipos.dart        # Listado + integración en el wizard
```

> Nota: existió una pantalla independiente `equipos_screen.dart` con el
> mismo listado que `step_equipos.dart`, pero nunca se enlazó desde
> ninguna otra pantalla (dead code). Se eliminó en la auditoría de
> 2026-08-06; `StepEquipos` es la única vía real para listar/editar
> equipos.
>
> Nota (2026-08-06): `agregar_editar_equipo_screen.dart` (pantalla
> completa) se reemplazó por `equipo_form_sheet.dart` (bottom sheet con
> "Guardar y agregar otro") para reducir la navegación al capturar varios
> equipos seguidos. El archivo de pantalla completa se eliminó por quedar
> sin ninguna referencia.

## Modelo: Equipo

```dart
@HiveType(typeId: 3)
class Equipo {
  @HiveField(0)
  String id;                           // ID único (auto-generado)
  
  @HiveField(1)
  String nombre;                       // Nombre del equipo
  
  @HiveField(2)
  double costoPorDia;                  // Costo diario de renta
  
  @HiveField(3)
  int dias;                            // Cantidad de días de renta
  
  // Getter: total = costoPorDia * dias
  double get total => costoPorDia * dias;
}
```

## Servicio: EquiposService

Singleton que gestiona todas las operaciones de equipos usando Hive.

### Inicialización

```dart
final equiposService = EquiposService();
await equiposService.initialize();
```

### Operaciones CRUD

```dart
// Agregar nuevo equipo
await equiposService.agregarEquipo(equipo);

// Obtener todos los equipos
List<Equipo> equipos = equiposService.obtenerEquipos();

// Obtener equipo por ID
Equipo? equipo = equiposService.obtenerEquipoPorId(id);

// Actualizar equipo
await equiposService.actualizarEquipo(equipo);

// Eliminar equipo
await equiposService.eliminarEquipo(id);

// Limpiar todos
await equiposService.limpiarEquipos();
```

### Cálculos

```dart
// Total general de todos los equipos
double total = equiposService.calcularTotalEquipos();

// Cantidad de equipos
int cantidad = equiposService.obtenerCantidadEquipos();

// Costo promedio por día
double promedioCosto = equiposService.calcularPromedioCostoDia();

// Días promedio
double promedioDias = equiposService.calcularPromedioDias();
```

## Pantallas

### 1. StepEquipos

Listado de equipos rentados embebido como paso del wizard, con:
- Lista de equipos (sin scroll propio, vive dentro del wizard)
- Información: nombre, días, costo/día, total
- Total general destacado
- Botón para agregar nuevo equipo
- Menú de opciones (editar, eliminar) por equipo

```dart
StepEquipos(
  equiposService: equiposService,
)
```

### 2. equipo_form_sheet.dart (mostrarHojaEquipo)

Bottom sheet para agregar o editar equipos con:
- Campo: Nombre del equipo (validación requerida)
- Campo: Costo por Día (validación numérica > 0, formato de moneda en vivo)
- Campo: Número de Días (validación numérica > 0)
- Cálculo automático: total = costoPorDia × días
- Botones: Guardar, Cancelar y "Guardar y agregar otro" (solo al agregar)

```dart
// Agregar nuevo
mostrarHojaEquipo(
  context: context,
  equiposService: equiposService,
  onCambio: _cargarEquipos,
)

// Editar existente
mostrarHojaEquipo(
  context: context,
  equiposService: equiposService,
  equipoEditando: equipo,
  onCambio: _cargarEquipos,
)
```

## Integración en Wizard

El módulo se integra en el wizard presupuesto como Step 4.

En `wizard_presupuesto_screen.dart`:

```dart
Step(
  title: const Text('Equipos'),
  content: StepEquipos(equiposService: _equiposService),
  isActive: _currentStep >= 3,
),
```

## Inicialización en main.dart

```dart
// Inicializar EquiposService (singleton)
final equiposService = EquiposService();
await equiposService.initialize();
```

## Ejemplo de Uso

```dart
import 'package:presupuesto_app/services/equipos_service.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';

// En un widget
final equiposService = EquiposService();

// Agregar un equipo
final equipo = Equipo(
  nombre: 'Grúa Telescópica',
  costoPorDia: 250.00,
  dias: 10,
);
await equiposService.agregarEquipo(equipo);

// Obtener total
double totalEquipos = equiposService.calcularTotalEquipos();

// El listado se muestra dentro del wizard vía StepEquipos(equiposService: equiposService)
```

## Características

✅ Modelo Hive con persistencia local  
✅ Singleton service pattern  
✅ CRUD completo (Create, Read, Update, Delete)  
✅ Cálculo automático y en tiempo real  
✅ Validaciones en formulario  
✅ UI intuitiva con Material Design  
✅ Total general destacado  
✅ Integración completa en wizard  
✅ Iconografía consistente (naranja para equipos)  

## Hive TypeId

- Equipos: `typeId: 2`

## Notas Técnicas

- El service es Singleton: siempre devuelve la misma instancia
- Usar `await equiposService.initialize()` antes de cualquier operación
- Los IDs se generan automáticamente con `DateTime.now().toString()`
- El total se calcula automáticamente con un getter
- Compatible con Hive y Flutter Material Design
