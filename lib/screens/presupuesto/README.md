# Presupuesto: Wizard de Captura y Pantalla de Resumen

## Descripción General

Este directorio tiene dos piezas independientes:

1. **`WizardPresupuestoScreen`** — el flujo de captura de un presupuesto,
   nuevo o en edición. Desde 2026-08-07 sigue el patrón **"una pregunta por
   pantalla"**: cada pantalla muestra una sola pregunta en letra grande, una
   línea de ayuda con ejemplo, el campo o las opciones, y botones fijos
   Atrás/Siguiente. Reemplazó al `Stepper` de 6 pasos que existía antes.
2. **`ResumenPresupuestoScreen`** — pantalla standalone para ver el
   desglose de un presupuesto ya guardado (no forma parte del wizard de
   captura). Sin cambios en este rediseño.

## Estructura de Archivos

```
lib/screens/presupuesto/
├── wizard_presupuesto_screen.dart    # Wizard de captura (una pregunta por pantalla)
├── resumen_presupuesto_screen.dart   # Pantalla standalone de solo lectura
├── widgets/
│   ├── seccion_materiales.dart       # Usados solo por ResumenPresupuestoScreen
│   ├── seccion_mano_obra.dart
│   ├── seccion_equipos.dart
│   └── seccion_finanzas.dart
└── wizard/
    ├── pregunta_scaffold.dart                  # Layout compartido de cada pantalla del wizard
    ├── agregar_material_screen.dart            # Mini-flujo: agregar/editar material
    ├── agregar_equipo_screen.dart              # Mini-flujo: agregar/editar equipo
    └── widgets/
        ├── opcion_grande.dart                  # OpcionGrande, SiNoGrande
        └── selector_porcentaje.dart            # SelectorPorcentaje (imprevistos/utilidad)
```

---

## 1. WizardPresupuestoScreen — flujo de captura

### El orden de las preguntas es dinámico

`WizardPresupuestoScreen` no tiene un número fijo de pasos: el getter
`_pasos` arma la lista según lo que el usuario ya respondió. Por ejemplo,
las preguntas de mano de obra "por día" (rol, personas, días, costo por
día) solo aparecen si el usuario contestó "Sí" a "¿Vas a pagar mano de
obra?" y eligió "Por día trabajado"; si eligió "Por contrato" aparecen en
su lugar "¿Cuánto va a costar toda la mano de obra?" y las observaciones.

Orden típico (cuando se responde "Sí" y "Por día" en mano de obra):

1. ¿Cómo quieres llamar a este presupuesto?
2. ¿De qué tamaño es la obra?
3. ¿Qué materiales vas a usar? (lista + agregar, no una pregunta por material)
4. ¿Vas a pagar mano de obra en este trabajo?
5. ¿Cómo le vas a pagar a tu gente?
6. ¿Qué tipo de trabajo van a hacer? / ¿Cuántas personas? / ¿Cuántos días? / ¿Cuánto por día?
7. ¿Vas a rentar o usar equipo para esta obra? (lista + agregar)
8. ¿Cuánto dinero extra quieres guardar por si algo sale mal? (imprevistos)
9. ¿Cuánto quieres ganar en este trabajo? (utilidad)
10. ¿El cliente necesita factura? (IVA)
11. Revisa tu presupuesto (resumen final, tocable por renglón)

### PreguntaScaffold

`lib/screens/presupuesto/wizard/pregunta_scaffold.dart` es el layout
compartido por **todas** las pantallas del wizard: encabezado "Pregunta X de
N", la pregunta en 25sp negrita, la ayuda debajo, el contenido específico
(`Expanded`), y — fijos abajo, siempre por encima del teclado — los botones
Atrás (56dp, gris) y Siguiente (56dp, amarillo con texto negro).

### Materiales y equipos: lista + mini-flujo, no una pregunta por ítem

Las preguntas "¿Qué materiales vas a usar?" y "¿Vas a rentar o usar equipo
para esta obra?" muestran una lista de lo ya agregado (o un estado vacío) y
un botón "Agregar". Agregar sí sigue el patrón de una pregunta por pantalla,
pero como un mini-flujo corto y separado:

- `AgregarMaterialScreen` (`wizard/agregar_material_screen.dart`): nombre →
  cantidad + unidad → precio (2 preguntas si el material viene del
  catálogo, que ya trae nombre fijo).
- `AgregarEquipoScreen` (`wizard/agregar_equipo_screen.dart`): nombre → días
  → costo por día.

Ambas son rutas empujadas con `Navigator.push` que devuelven su resultado
con `Navigator.pop(...)`; quien las abre (`_abrirAgregarMaterial`,
`_abrirAgregarEquipo`, etc., en `wizard_presupuesto_screen.dart`) guarda el
resultado en el servicio correspondiente y llama `setState` +
`_programarAutoguardado()`. Ver también `lib/screens/materiales/README.md`
y `lib/screens/equipos/README.md`.

### Finanzas: tres preguntas, sin pantalla propia

Imprevistos, utilidad e IVA ya no tienen una pantalla "Finanzas" separada:
son tres preguntas más de la misma lista `_pasos`, usando `SelectorPorcentaje`
(botones de porcentaje + "Otro", con el monto resultante en pesos siempre
visible) y `SiNoGrande`. Detalle completo en `lib/screens/finanzas/README.md`.

### Botones/tarjetas de opción reutilizables

`lib/screens/presupuesto/wizard/widgets/opcion_grande.dart` define:
- `OpcionGrande`: tarjeta grande y tocable (mínimo 72dp de alto) para elegir
  entre pocas opciones, en vez de un dropdown.
- `SiNoGrande`: dos botones grandes de Sí/No (88dp de alto), en vez de un
  `Switch`.

### Autoguardado de borrador

Cada mutación de estado relevante (título, superficie, mano de obra,
materiales, equipos, imprevistos, utilidad, IVA, fecha) llama a
`_programarAutoguardado()`, que hace debounce de 900ms y guarda un
`BorradorPresupuesto` en Hive (`BorradorPresupuestoService`). También se
guarda al pausar/inactivar el ciclo de vida de la app
(`didChangeAppLifecycleState`). Al reabrir el wizard con un borrador
pendiente, se pregunta si continuarlo o empezar de nuevo; si se continúa,
`_pasoIndex` se restaura (con `clamp` sobre la lista de pasos vigente, por
si las respuestas guardadas ya no arman exactamente los mismos pasos).

### Pantalla de resumen final

`_pasoResumen()` (dentro de `wizard_presupuesto_screen.dart`, no un archivo
aparte) muestra el desglose en lenguaje de persona: "Materiales",
"Mano de obra", "Equipos", "Dinero extra (X%)", "Tu ganancia (X%)",
"IVA (16%)" si aplica, y el TOTAL destacado. Cada renglón es tocable y
regresa a la pregunta correspondiente vía `_irASeccion(_PasoId...)`.

---

## 2. ResumenPresupuestoScreen — pantalla standalone

Esta pantalla **no** forma parte del wizard de captura: se abre desde la
vista de un proyecto (`proyectos_vista.dart`) para ver, de solo lectura, el
desglose de un presupuesto ya guardado. No cambió con este rediseño.

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

### Características
- Scaffold completo con AppBar
- Botones "Guardar" y "Exportar"
- Desglose de componentes en barras de progreso
- Muestra porcentaje de cada componente respecto al total
- El widget no es Stateful: todos los cálculos se hacen en `build()` con
  `CalculadoraFinanzas`

### Widgets Auxiliares (usados solo por esta pantalla)

#### SeccionMateriales
```dart
SeccionMateriales(materiales: List<MaterialPresupuesto>)
```
Lista de materiales con nombre, cantidad, precio unitario y total (azul).

#### SeccionManoObra
```dart
SeccionManoObra(manoObra: List<ManoObra>)
```
Lista con rol, cantidad de personas, días, y total (púrpura).

#### SeccionEquipos
```dart
SeccionEquipos(equipos: List<Equipo>)
```
Lista de equipos con nombre, días, costo por día, y total (naranja).

#### SeccionFinanzas
```dart
SeccionFinanzas(
  totalMateriales: double,
  totalManoObra: double,
  totalEquipos: double,
  finanzas: Finanzas,
)
```
Costo directo, imprevistos, subtotal, utilidad, precio final, IVA (si
aplica).

### Colores y Estilos

| Componente | Color | Uso |
|-----------|-------|-----|
| Materiales | Azul | Total y cards |
| Mano Obra | Púrpura | Total y cards |
| Equipos | Naranja | Total y cards |
| Imprevistos | Ámbar | Barra de progreso |
| Utilidad | Verde Azulado | Barra de progreso |
| IVA | Rojo | Barra de progreso |
| Total Final | Verde | Highlight principal |

> Nota: estos colores son específicos de `ResumenPresupuestoScreen` y sus
> `Seccion*`. El wizard de captura usa exclusivamente la paleta industrial
> amarillo/negro/gris de `lib/core/theme/app_colors.dart`.

### Casos de Uso

#### 1. Abrir resumen de un presupuesto guardado
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

#### 2. Exportar presupuesto
El botón "Exportar" puede:
- Generar PDF
- Enviar email
- Guardar en archivo

---

## Próximas Mejoras Sugeridas

- [ ] Exportar a PDF con diseño profesional
- [ ] Enviar presupuesto por email
- [ ] Comparar múltiples presupuestos
- [ ] Historial de presupuestos
- [ ] Firmas digitales
- [ ] QR con enlace al presupuesto
