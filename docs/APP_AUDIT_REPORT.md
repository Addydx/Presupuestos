# Auditoría de la aplicación Presupuesto App

**Fecha:** 2026-08-06
**Alcance:** Inspección completa, limpieza segura de código no usado y verificación funcional del proyecto Flutter, sin cambios de diseño ni reescrituras.

---

## 1. Resumen ejecutivo

La aplicación es funcional: compila, sus pruebas pasan y se instaló y ejecutó correctamente en un emulador Android (`emulator-5554`), donde se navegó por la pantalla de inicio y el formulario de "Nuevo Proyecto" sin errores. No se encontraron errores de compilación antes ni después de la auditoría.

Se identificaron y eliminaron 5 elementos con falta de uso demostrada (3 archivos vacíos abandonados, 1 pantalla huérfana duplicada y 1 asset de imagen sin referencias), se corrigió una prueba obsoleta que estaba **fallando** (probaba un contador que no existe en la app real), y se arregló la única causa de dos `warning` reales de `flutter analyze`. El resto de los ~209 avisos de `flutter analyze` son de severidad `info` (principalmente `avoid_print` y APIs deprecadas de Flutter) y se documentan como deuda técnica en la sección 11, tal como se pidió: sin corrección masiva.

También se preservó, sin tocar, la corrección previa de directorios `lib/models/presupuesto` y `lib/models/proyectos` en minúsculas (necesaria porque Linux distingue mayúsculas/minúsculas), y la reestructuración ya en marcha (staged) que mueve el proyecto desde `presupuesto_app/` a la raíz del repositorio.

---

## 2. Propósito actual de la aplicación

"Presupuesto App" es una app Android (Flutter) para que constructores, contratistas o maestros de obra creen y administren **presupuestos de construcción**: agrupan materiales, mano de obra y equipos rentados por proyecto, aplican imprevistos/utilidad/IVA, y generan un resumen exportable en PDF. Esto se confirma tanto por el código (`lib/screens/info/info_screen.dart`) como por el flujo real de pantallas.

---

## 3. Características principales confirmadas

Confirmadas leyendo el código (no asumidas):

- **Gestión de proyectos**: crear (`NuevoProyectoScreen`), editar (`EditarProyectoScreen`), ver detalle con lista de presupuestos (`ProyectosVista`) y eliminar (con eliminación en cascada de sus presupuestos). Cada proyecto admite nombre, cliente, descripción, ubicación, fechas y una foto (vía `image_picker`, cámara o galería).
- **Wizard de presupuestos** (`WizardPresupuestoScreen`, 5 pasos): información general → mano de obra → materiales → equipos → finanzas → resumen. Sirve tanto para crear como para editar un presupuesto existente.
- **Materiales**: catálogo reutilizable con 18 materiales semilla (`MaterialesSeed`, categorías: Estructural, etc.), búsqueda/filtro por categoría, materiales personalizados por presupuesto, y cálculo de subtotales por categoría.
- **Mano de obra**: por día (personas × días × costo/día) o por contrato (monto fijo).
- **Equipos rentados**: alta/edición/borrado con cálculo automático (`costoPorDia × días`); el listado vive embebido en el wizard (`StepEquipos`), no en una pantalla independiente (ver sección 5).
- **Cálculo financiero** (`CalculadoraFinanzas`): costo directo → imprevistos (%) → subtotal → utilidad (%) → precio final → IVA opcional (16%) → total final.
- **Persistencia local con Hive**: cajas (`boxes`) separadas para `proyectos`, `presupuestos`, `materiales_catalogo` y `equipos`; los materiales/equipos "en edición" del wizard se mantienen en memoria en los servicios singleton y se guardan en el `Presupuesto` al finalizar.
- **Exportación a PDF** (`PdfService`, paquetes `pdf`/`printing`): genera un documento con tablas de materiales, mano de obra, equipos y resumen financiero, y abre el diálogo de impresión/compartir del sistema.
- **Pantallas de Información y Configuración**: información general de la app; configuración con selector de moneda (solo UI, no aplicado a cálculos), "modo oscuro" marcado explícitamente como "Próximamente" (switch deshabilitado), y una opción de "Eliminar todos los datos" que limpia todas las cajas de Hive.
- **Navegación**: `Splash → Home` (con `BottomNavigationBar` de 3 pestañas: Proyectos, Información, Configuración) → flujos internos de cada módulo.

---

## 4. Arquitectura y flujo general

```
lib/
├── main.dart                  # Inicializa Hive, registra adapters, abre boxes, runApp
├── models/                    # Modelos Hive (@HiveType) + *.g.dart generados
│   ├── proyectos/             # Proyecto, EstadoProyecto (enum sin usar, ver §11)
│   └── presupuesto/           # Presupuesto, Equipo, ManoObra, Material(Presupuesto), MaterialCatalogo, Finanzas
├── services/                  # Lógica de negocio + acceso a Hive (patrón singleton)
│   ├── presupuestos_service.dart, materiales_service.dart, equipos_service.dart
│   ├── calculadora_finanzas.dart, pdf_service.dart, materiales_seed.dart
├── screens/                   # UI, organizada por módulo (proyectos, presupuesto, materiales, equipos, finanzas, settings, info, splash, home)
└── data/                      # vacío tras la limpieza (ver §5)
```

No hay una capa de "repositorio" real: las pantallas y servicios acceden a Hive directamente (`Hive.box<T>(...)`). Los archivos que sí planteaban esa capa (`lib/data/repositories/proyecto_repository.dart`, `lib/data/local/hive_service.dart`) estaban vacíos y sin usar; se eliminaron (ver §5).

Flujo típico: `HomeScreen` → `ProyectosScreens` (lista) → `NuevoProyectoScreen`/`ProyectosVista` → `WizardPresupuestoScreen` (5 pasos, usando los servicios singleton de materiales/equipos como estado temporal) → al guardar, arma un `Presupuesto` y lo persiste vía `PresupuestosService` → `ResumenPresupuestoScreen` permite exportar a PDF.

---

## 5. Archivos y elementos eliminados, con justificación

Todos verificados con búsqueda global (`grep -r`) antes de borrar; ninguno tenía referencias.

| Elemento | Tipo | Justificación |
|---|---|---|
| `lib/data/repositories/proyecto_repository.dart` | Archivo vacío (0 bytes) | Sin contenido, sin imports hacia él en todo el repo. La persistencia de `Proyecto` se hace directamente en las pantallas vía `Hive.box<Proyecto>('proyectos')`. |
| `lib/data/local/hive_service.dart` | Archivo vacío (0 bytes) | Igual que el anterior: stub abandonado, cero referencias. |
| `lib/core/utils/calculadora_financiera.dart` | Archivo vacío (0 bytes) | Duplicado abandonado de `lib/services/calculadora_finanzas.dart`, que es el que realmente se usa en toda la app. |
| `lib/screens/equipos/equipos_screen.dart` | Pantalla completa (254 líneas) nunca importada | `EquiposScreen` no aparece referenciada desde ningún otro archivo `.dart` del proyecto. Fue reemplazada por `StepEquipos` (`lib/screens/presupuesto/steps/step_equipos.dart`), que implementa el mismo listado embebido en el wizard. `AgregarEditarEquipoScreen` (el formulario) sí se sigue usando, desde `step_equipos.dart`, y se conservó intacta. |
| `assets/images/construccion-de-una-casa-de-dos-pisos-1.webp` | Asset de imagen (32 KB) | Sin ninguna referencia en el código (`grep` global sobre `.dart`, `.xml`, `.yaml`, `.plist`). El único asset de imagen realmente usado es `assets/gif/Building.gif` (en el splash). |

**Documentación actualizada por la eliminación anterior:** `lib/screens/equipos/README.md` mencionaba y daba ejemplos de `EquiposScreen`; se actualizó para reflejar que `StepEquipos` es la vía real, y se corrigió un dato incorrecto preexistente (`typeId` de `Equipo` decía `3`, el modelo real usa `typeId: 2`).

**No se tocaron** (dependencias declaradas en `pubspec.yaml` sin `import` directo en `lib/`): `cupertino_icons` (se usa vía `flutter/cupertino.dart`, no se importa por nombre — falso positivo típico) y `path_provider` (usado transitivamente por `hive_flutter`/`printing` para resolver rutas de almacenamiento). Eliminarlas sin evidencia más fuerte que "no hay import directo" habría sido arriesgado; se documentan como punto a revisar en §11 si se quiere confirmar con `flutter pub deps` u otra herramienta dedicada.

**No se tocó** el enum `EstadoProyecto` (`lib/models/proyectos/estado_proyecto.dart` + adapter registrado en `main.dart`): no se usa como campo de `Proyecto` ni en ningún otro lugar, pero podría ser infraestructura preparada para una futura función de "estado del proyecto". No se pudo demostrar que sea código muerto vs. incompleto, así que se conserva y se documenta como deuda técnica.

---

## 6. Mejoras realizadas (además de la limpieza)

- **Prueba obsoleta corregida**: `test/widget_test.dart` era el test de ejemplo por defecto de `flutter create` (contador "+1"), que **fallaba** porque la app real no tiene ningún contador. Se reemplazó por un smoke test real que monta `MyApp`, verifica que la pantalla de splash se muestra ("Presupuesto App" / "Gestión profesional de presupuestos") y desmonta el árbol antes de que se dispare el temporizador de navegación del splash (evita el error "A Timer is still pending" de `flutter_test`).
- **2 warnings reales corregidos** (los únicos que arrojaba `flutter analyze`):
  - `lib/screens/presupuesto/widgets/seccion_mano_obra.dart`: variable local `tipoStr` calculada y nunca usada — eliminada.
  - `lib/screens/settings/settings_screen.dart`: campo `_darkModeEnabled` nunca reasignado (el switch de "modo oscuro" está deshabilitado, marcado "Próximamente") — se marcó `final`.

No se aplicó ninguna corrección masiva sobre los ~209 avisos `info` restantes, según lo solicitado (ver §11).

---

## 7. Validaciones ejecutadas y resultados

Todas ejecutadas con Flutter 3.44.8 / Dart 3.12.2, sobre `emulator-5554` (Android) cuando aplica.

| Comando | Antes de la limpieza | Después de la limpieza |
|---|---|---|
| `flutter pub get` | ✅ OK (50 paquetes con versiones más nuevas disponibles, sin bloquear) | ✅ OK |
| `flutter analyze` | 211 issues (2 warnings + 209 info), **0 errores** | 209 issues (0 warnings + 209 info), **0 errores** |
| `flutter test` | ❌ Falla (`test/widget_test.dart` — probaba un contador inexistente) | ✅ 1/1 pruebas pasan |
| `flutter build apk --debug` | ✅ `build/app/outputs/flutter-apk/app-debug.apk` generado (solo warnings benignos de Gradle/AGP/Kotlin/NDK, sin errores) | ✅ Igual, build reproducido exitosamente |
| `dart format .` | — | 9 archivos reformateados (solo estilo/indentación, sin cambios de lógica; ver §8) |
| Ejecución en `emulator-5554` | — | ✅ App instalada y lanzada sin crashes. Verificado visualmente: pantalla "Mis Proyectos" (vacía) y formulario "Nuevo Proyecto" renderizan correctamente. Logcat sin `FATAL EXCEPTION`. |

---

## 8. Comparación de `flutter analyze`: antes vs. después

| Severidad | Antes | Después | Diferencia |
|---|---:|---:|---:|
| error | 0 | 0 | — |
| warning | 2 | 0 | -2 (ambos corregidos, ver §6) |
| info | 209 | 209 | 0 (documentados como deuda técnica, no se tocaron) |
| **Total** | **211** | **209** | **-2** |

Distribución de los 209 `info` restantes (sin cambios, se listan por transparencia):

| Regla | Cantidad | Nota |
|---|---:|---|
| `avoid_print` | 163 | Casi todo concentrado en `presupuestos_service.dart` (15), `wizard_presupuesto_screen.dart` (6) y `materiales_seed.dart` (3) — más el resto disperso en logs de depuración. |
| `deprecated_member_use` | 30 | `withOpacity` → `withValues`, `value` → `initialValue` en `DropdownButtonFormField`, `useMaterial3`, `groupValue`/`onChanged` de `Radio`, etc. — APIs de Flutter que cambiaron pero siguen funcionando. |
| `use_build_context_synchronously` | 4 | Uso de `BuildContext` tras un `await` sin `mounted`/`context.mounted` check en 4 puntos puntuales. |
| `file_names` | 4 | Los 4 archivos `EJEMPLOS_*.dart` en la raíz del repo (no están en `lib/`, no se compilan como parte de la app — ver §11). |
| `non_constant_identifier_names` | 3 | En `EJEMPLOS_RESUMEN.dart` (mismo grupo que el anterior). |
| `dangling_library_doc_comments` | 2 | Ídem, en `EJEMPLOS_FINANZAS.dart` y `EJEMPLOS_RESUMEN.dart`. |
| `unnecessary_to_list_in_spreads` | 1 | `lib/screens/materiales/catalogo_materiales_screen.dart:149`. |
| `prefer_final_fields` | 0 | *(era 1, corregido — ver §6)* |
| `constant_identifier_names` | 1 | `IVA_RATE` en `calculadora_finanzas.dart` (constante en mayúsculas por convención propia del equipo). |

---

## 9. Estado actual

**Funcional.** La app compila sin errores, todas las pruebas pasan, y se verificó ejecución real en emulador Android sin crashes, incluyendo un flujo de UI completo (navegar a "Nuevo Proyecto" y ver el formulario renderizado). No se verificaron manualmente todos los flujos (p. ej. completar el wizard de 5 pasos hasta guardar un presupuesto, exportar un PDF, o editar/eliminar un proyecto existente) — ver §10.

---

## 10. Problemas conocidos

- **No se ejecutó manualmente el flujo completo de creación de un presupuesto** (los 5 pasos del wizard) ni la exportación a PDF; solo se verificó que la app arranca y que la pantalla de creación de proyecto se renderiza. Recomendado como siguiente paso de QA manual.
- **Selector de moneda en Configuración es solo visual**: cambiar la moneda no afecta ningún cálculo ni formato en el resto de la app (`CalculadoraFinanzas.formatoMoneda` siempre usa `$`).
- **Toolchain de Android desactualizado** respecto a lo que Flutter 3.44.8 recomienda: Gradle 8.11.1 (recomendado ≥8.14.0), Android Gradle Plugin 8.9.1 (recomendado ≥8.11.1), Kotlin 2.1.0 (recomendado ≥2.2.20), y NDK 27.0.12077973 vs. 28.2.13676358 que pide el plugin `integration_test`. Ninguno bloquea el build (son warnings), pero conviene planificar la actualización.
- `pubspec.lock` y `android/gradle.properties` cambiaron como efecto secundario de ejecutar `flutter pub get`/`flutter build apk` con la versión de Flutter instalada en este equipo (bump de versiones transitivas y dos flags que el "Flutter migrator" añadió automáticamente). Son cambios esperados y necesarios para que el build funcione en este entorno; se incluyen en el commit de esta auditoría.

---

## 11. Deuda técnica restante (por prioridad)

1. **`avoid_print` (163 ocurrencias)** — Reemplazar `print(...)` por un logger real (o al menos `debugPrint`, que ya se usa en otras partes como `proyectos_screens.dart`) antes de publicar en producción, ya que `print` en Flutter puede truncar mensajes largos y no se puede filtrar por nivel. Concentrado sobre todo en `presupuestos_service.dart` y `materiales_seed.dart`.
2. **`deprecated_member_use` (30 ocurrencias)** — Migrar `withOpacity` → `withValues(alpha:)`, `value` → `initialValue` en formularios, `Radio`/`RadioListTile` a `RadioGroup`. Ninguna es urgente (siguen funcionando), pero se acumularán con cada nueva versión de Flutter.
3. **Los 4 archivos `EJEMPLOS_*.dart` en la raíz del repositorio** (`EJEMPLOS_EQUIPOS.dart`, `EJEMPLOS_FINANZAS.dart`, `EJEMPLOS_MATERIALES.dart`, `EJEMPLOS_RESUMEN.dart`) y `IMPLEMENTACION_MATERIALES.md` — Son código/documentación de ejemplo de uso de los servicios, no se compilan como parte de la app ni se referencian desde `lib/` o `test/`, y generan 10 de los 209 avisos de `analyze`. No se eliminaron porque podrían tener valor como documentación de referencia para el equipo y no hay evidencia de que sean "basura" vs. "documentación viva". **Recomendación:** moverlos a una carpeta `docs/examples/` (fuera del análisis de lint del paquete) o confirmar con el equipo si se pueden borrar.
4. **`EstadoProyecto` (enum + adapter Hive registrado, `typeId: 9`)** — Definido pero no usado como campo de `Proyecto` ni en ninguna pantalla. Puede ser una función planeada (estado del proyecto: pendiente/activo/completado/cancelado) que quedó a medias. Confirmar con el equipo si se implementa o se retira.
5. **`use_build_context_synchronously` (4 ocurrencias)** — Riesgo real pero bajo de usar un `BuildContext` inválido tras una operación async sin verificar `mounted`.
6. **Selector de moneda no funcional** (ver §10) — Definir si es un placeholder a futuro o si debe eliminarse hasta implementarse.
7. **Actualización del toolchain Android** (Gradle/AGP/Kotlin/NDK, ver §10) — No urgente, pero Flutter dejará de darle soporte pronto.
8. **Dependencias `cupertino_icons` y `path_provider`** — Sin `import` directo detectado en `lib/`; probablemente necesarias igual (ver §5), pero valdría la pena confirmarlo con `flutter pub deps` o `dependency_validator` en vez de solo `grep`.

---

## 12. Próximos tres pasos recomendados

1. **QA manual del flujo completo**: crear un proyecto → completar los 5 pasos del wizard → guardar un presupuesto → exportar a PDF → editar y eliminar, todo en el emulador, para cerrar la brecha de verificación mencionada en §10.
2. **Sustituir `print` por un logger** en los servicios (empezando por `presupuestos_service.dart`, el archivo con más ocurrencias) antes de cualquier build de release.
3. **Decidir el destino de los archivos `EJEMPLOS_*.dart`/`IMPLEMENTACION_MATERIALES.md`** y del enum `EstadoProyecto` (§11, puntos 3 y 4) con el resto del equipo, ya que ninguno se pudo eliminar de forma segura sin esa confirmación.
