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
│   │   ├── equipos_screen.dart      # Pantalla de listado de equipos
│   │   └── agregar_editar_equipo_screen.dart  # Formulario add/edit
│   └── presupuesto/steps/
│       └── step_equipos.dart        # Integración en wizard
```

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

### 1. EquiposScreen

Listado completo de equipos rentados con:
- Lista scrolleable de equipos
- Información: nombre, días, costo/día, total
- Total general destacado
- Botón FAB para agregar nuevo equipo
- Menú de opciones (editar, eliminar) por equipo

```dart
EquiposScreen(
  equiposService: equiposService,
)
```

### 2. AgregarEditarEquipoScreen

Formulario para agregar o editar equipos con:
- Campo: Nombre del equipo (validación requerida)
- Campo: Costo por Día (validación numérica > 0)
- Campo: Número de Días (validación numérica > 0)
- Cálculo automático: total = costoPorDia × días
- Visualización en tiempo real del total
- Botones: Guardar, Cancelar

```dart
// Agregar nuevo
AgregarEditarEquipoScreen(
  equiposService: equiposService,
)

// Editar existente
AgregarEditarEquipoScreen(
  equiposService: equiposService,
  equipoEditando: equipo,
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
import 'package:presupuesto_app/screens/equipos/equipos_screen.dart';

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

// Mostrar pantalla
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EquiposScreen(
      equiposService: equiposService,
    ),
  ),
);
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

- Equipos: `typeId: 3`

## Notas Técnicas

- El service es Singleton: siempre devuelve la misma instancia
- Usar `await equiposService.initialize()` antes de cualquier operación
- Los IDs se generan automáticamente con `DateTime.now().toString()`
- El total se calcula automáticamente con un getter
- Compatible con Hive y Flutter Material Design
