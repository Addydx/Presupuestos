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
└── screens/presupuesto/
    ├── wizard_presupuesto_screen.dart          # Pantalla "¿Vas a rentar o usar equipo...?" (lista)
    └── wizard/agregar_equipo_screen.dart       # Mini-flujo de 3 preguntas para agregar/editar
```

> Nota histórica: existió una pantalla independiente `equipos_screen.dart`
> con el mismo listado, nunca enlazada desde ninguna otra pantalla (dead
> code). Se eliminó en la auditoría de 2026-08-06.
>
> Nota histórica (2026-08-06): `agregar_editar_equipo_screen.dart` (pantalla
> completa) se reemplazó por `equipo_form_sheet.dart` (bottom sheet).
>
> Nota histórica (2026-08-07): el wizard completo se rediseñó a "una
> pregunta por pantalla". `step_equipos.dart` (listado embebido en un
> `Stepper`) y `equipo_form_sheet.dart` (bottom sheet de alta/edición) se
> eliminaron; los reemplazan la pantalla de lista dentro del wizard y
> `agregar_equipo_screen.dart` respectivamente, descritos abajo.

## Modelo: Equipo

```dart
@HiveType(typeId: 2)
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

### 1. Pregunta "¿Vas a rentar o usar equipo para esta obra?"

**Ubicación**: `_pasoEquipos()` en `lib/screens/presupuesto/wizard_presupuesto_screen.dart`

Listado de equipos ya agregados, con:
- Tarjetas grandes: nombre, días × costo/día, total
- Botón "Agregar equipo" (abre `AgregarEquipoScreen`)
- Editar/eliminar por tarjeta (con confirmación al eliminar)
- Estado vacío: "Todavía no agregas equipos. Toca el botón para agregar el primero."
- Siempre se puede tocar "Siguiente" sin agregar nada

```dart
Future<void> _abrirAgregarEquipo() async {
  final resultado = await Navigator.push<Equipo>(
    context,
    MaterialPageRoute(builder: (context) => const AgregarEquipoScreen()),
  );
  if (resultado == null) return;
  await _equiposService.agregarEquipo(resultado);
  if (!mounted) return;
  setState(() {});
  _programarAutoguardado();
}
```

### 2. AgregarEquipoScreen (mini-flujo de una pregunta por pantalla)

**Ubicación**: `lib/screens/presupuesto/wizard/agregar_equipo_screen.dart`

Reemplaza al bottom sheet anterior. Tres preguntas, una por pantalla:
1. ¿Qué equipo vas a usar? (nombre, validación requerida)
2. ¿Cuántos días lo vas a usar? (validación numérica entera > 0)
3. ¿Cuánto cuesta por día? (validación numérica > 0, formato de moneda en vivo, con caja de "Total de este equipo" en vivo)

Al terminar (`Navigator.pop` con el `Equipo` resultante), quien llamó a la
pantalla (`_abrirAgregarEquipo`/`_abrirEditarEquipo` en el wizard) es
responsable de guardarlo con `EquiposService`.

## Integración en el Wizard

El paso "Equipos" es una pregunta más dentro de la lista dinámica `_pasos`
de `wizard_presupuesto_screen.dart` — no hay `Stepper` ni pasos numerados
fijos. El usuario puede volver a "Equipos" en cualquier momento desde la
pantalla de resumen final (tocando el renglón "Equipos").

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
```

## Características

✅ Modelo Hive con persistencia local
✅ Singleton service pattern
✅ CRUD completo (Create, Read, Update, Delete)
✅ Cálculo automático y en tiempo real
✅ Validaciones en formulario
✅ UI de una pregunta por pantalla, lenguaje simple
✅ Total general destacado
✅ Integración completa en el wizard

## Hive TypeId

- Equipos: `typeId: 2`

## Notas Técnicas

- El service es Singleton: siempre devuelve la misma instancia
- Usar `await equiposService.initialize()` antes de cualquier operación
- Los IDs se generan automáticamente con `DateTime.now().toString()`
- El total se calcula automáticamente con un getter
- Compatible con Hive y Flutter Material Design
