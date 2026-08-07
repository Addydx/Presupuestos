# Módulo de Finanzas

## Descripción General

El módulo de Finanzas proporciona herramientas para calcular y gestionar los aspectos financieros de un presupuesto de construcción. Incluye cálculos automáticos de imprevistos, utilidad, IVA y generación de totales finales.

Desde 2026-08-07 la captura de estos tres parámetros (imprevistos, utilidad,
IVA) es parte del flujo de **"una pregunta por pantalla"** del wizard — ya
no existe una pantalla `FinanzasScreen` independiente. Ver el detalle en la
sección "Preguntas de Finanzas en el Wizard" más abajo. La lógica de
cálculo (`CalculadoraFinanzas`) no cambió.

## Estructura de Archivos

```
lib/
├── models/presupuesto/
│   └── finanzas.dart                 # Modelo de datos Hive
├── services/
│   └── calculadora_finanzas.dart     # Servicio singleton de cálculos
└── screens/presupuesto/
    ├── wizard_presupuesto_screen.dart              # Preguntas de imprevistos/utilidad/IVA + resumen
    └── wizard/widgets/selector_porcentaje.dart     # Widget compartido: botones % + "Otro" + monto en vivo
```

## Modelo: Finanzas

```dart
@HiveType(typeId: 3)
class Finanzas {
  @HiveField(0)
  double porcentajeImprevistos;    // Ej: 5, 10, 15

  @HiveField(1)
  double porcentajeUtilidad;       // Ej: 20, 25, 30

  @HiveField(2)
  bool aplicarIVA;                 // true o false

  Finanzas({
    this.porcentajeImprevistos = 5.0,
    this.porcentajeUtilidad = 20.0,
    this.aplicarIVA = true,
  });
}
```

### Parámetros

| Campo | Tipo | Descripción | Valor por Defecto |
|-------|------|-------------|-------------------|
| `porcentajeImprevistos` | double | Porcentaje para imprevistos | 5.0 |
| `porcentajeUtilidad` | double | Porcentaje de ganancia | 20.0 |
| `aplicarIVA` | bool | Cargar 16% de IVA | true |

## Servicio: CalculadoraFinanzas

### Patrón Singleton

```dart
final calculadora = CalculadoraFinanzas();
```

### Métodos Disponibles

#### 1. `costoDirecto()`
Suma total de materiales, mano de obra y equipos.

```dart
double costo = calculadora.costoDirecto(
  totalMateriales: 5000,
  totalManoObra: 3000,
  totalEquipos: 2000,
);
// Resultado: 10000
```

#### 2. `imprevistos()`
Calcula el monto de imprevistos como porcentaje del costo directo.

```dart
double impres = calculadora.imprevistos(
  costoDirecto: 10000,
  porcentajeImprevistos: 5,
);
// Resultado: 500 (5% de 10000)
```

#### 3. `subtotal()`
Suma el costo directo más los imprevistos.

```dart
double sub = calculadora.subtotal(
  costoDirecto: 10000,
  imprevistos: 500,
);
// Resultado: 10500
```

#### 4. `utilidad()`
Calcula el margen de ganancia.

```dart
double util = calculadora.utilidad(
  subtotal: 10500,
  porcentajeUtilidad: 20,
);
// Resultado: 2100 (20% de 10500)
```

#### 5. `precioFinal()`
Suma del subtotal más la utilidad.

```dart
double precio = calculadora.precioFinal(
  subtotal: 10500,
  utilidad: 2100,
);
// Resultado: 12600
```

#### 6. `iva()`
Calcula el IVA sobre el precio final.

```dart
double ivaAuto = calculadora.iva(
  precioFinal: 12600,
  aplicarIVA: true,
);
// Resultado: 2016 (16% de 12600)
```

#### 7. `totalFinal()`
Suma del precio final más IVA.

```dart
double total = calculadora.totalFinal(
  precioFinal: 12600,
  iva: 2016,
);
// Resultado: 14616
```

#### 8. `calcularTodo()` ⭐ **Recomendado**

Método conveniente que calcula TODOS los valores en una sola llamada y retorna un mapa.

```dart
Map<String, double> resultados = calculadora.calcularTodo(
  totalMateriales: 5000,
  totalManoObra: 3000,
  totalEquipos: 2000,
  finanzas: Finanzas(
    porcentajeImprevistos: 5,
    porcentajeUtilidad: 20,
    aplicarIVA: true,
  ),
);

// Acceder a los valores
double costoDirecto = resultados['costoDirecto']!;
double imprevistos = resultados['imprevistos']!;
double subtotal = resultados['subtotal']!;
double utilidad = resultados['utilidad']!;
double precioFinal = resultados['precioFinal']!;
double iva = resultados['iva']!;
double totalFinal = resultados['totalFinal']!;
```

#### 9. `formatoMoneda()`
Convierte un número a formato de moneda.

```dart
String texto = calculadora.formatoMoneda(14616.50);
// Resultado: "$14616.50"
```

## Preguntas de Finanzas en el Wizard

No hay pantalla ni widget "Finanzas" independiente: son tres preguntas más
dentro de la lista dinámica `_pasos` de `wizard_presupuesto_screen.dart`,
cada una en lenguaje simple (sin usar los términos contables "imprevistos"
o "utilidad" en la pregunta que ve el usuario):

| Paso | Pregunta | Ayuda | Widget |
|---|---|---|---|
| Imprevistos | ¿Cuánto dinero extra quieres guardar por si algo sale mal? | Lo normal es 5%. Si dejas 5%, guardas $500 de cada $10,000. | `SelectorPorcentaje` (botones 5/10/15% + "Otro", con el monto resultante en pesos siempre visible) |
| Utilidad | ¿Cuánto quieres ganar en este trabajo? | Es tu pago por hacer el trabajo, después de cubrir materiales, mano de obra y el dinero extra. | `SelectorPorcentaje` (botones 10/15/20/25% + "Otro") |
| IVA | ¿El cliente necesita factura? | Si pide factura, se suma el 16% de IVA. | `SiNoGrande` (Sí/No) |

`SelectorPorcentaje` (`lib/screens/presupuesto/wizard/widgets/selector_porcentaje.dart`)
es un widget de exhibición pura: el estado (qué botón está activo, el texto
de "Otro") lo posee `WizardPresupuestoScreen`, para poder restaurarlo desde
un borrador sin duplicar lógica. Los totales se leen en vivo con
`_resultadosActuales` (que llama a `CalculadoraFinanzas.calcularTodo()` en
cada `build()`), igual que antes.

La pantalla de resumen final (`_pasoResumen()`) muestra el desglose completo
("Dinero extra (5%)", "Tu ganancia (20%)", "IVA (16%)", "TOTAL") y cada
renglón es tocable para volver a la pregunta correspondiente.

## Fórmulas Matemáticas

### 1. Costo Directo
```
CostoDirecto = Materiales + ManoObra + Equipos
```

### 2. Imprevistos
```
Imprevistos = CostoDirecto × (PorcentajeImprevistos / 100)
```

### 3. Subtotal
```
Subtotal = CostoDirecto + Imprevistos
```

### 4. Utilidad
```
Utilidad = Subtotal × (PorcentajeUtilidad / 100)
```

### 5. Precio Final (antes de IVA)
```
PrecioFinal = Subtotal + Utilidad
```

### 6. IVA (opcional)
```
IVA = PrecioFinal × 0.16   (si aplicarIVA == true)
      0                     (si aplicarIVA == false)
```

### 7. Total Final
```
TotalFinal = PrecioFinal + IVA
```

## Ejemplo Completo

### Escenario: Pequeña reparación

```
Costos:
- Materiales: $5,000
- Mano de obra: $3,000
- Equipos: $2,000
- Total directo: $10,000

Parámetros:
- Imprevistos: 5%
- Utilidad: 20%
- IVA: Sí

Cálculos:
1. Costo directo = $10,000
2. Imprevistos = $500 (5%)
3. Subtotal = $10,500
4. Utilidad = $2,100 (20%)
5. Precio final = $12,600
6. IVA = $2,016 (16%)
7. TOTAL = $14,616
```

## Testing

Para verificar los cálculos, ejecuta:

```bash
dart EJEMPLOS_FINANZAS.dart
```

Esto muestra 6 ejemplos diferentes de cálculos financieros.

## Notas Importantes

✅ **El TotalFinal es el precio que se facturaría al cliente**

✅ **Los totales se recalculan en vivo mientras el usuario toca los botones de porcentaje o cambia materiales/mano de obra/equipos**

✅ **El modelo se guarda automáticamente como borrador (Hive) con cada cambio, y como Presupuesto final al terminar el wizard**

✅ **El IVA solo se aplica si la opción está habilitada**

## Constantes

```dart
static const double IVA_RATE = 0.16;  // 16% IVA
```

## Limitaciones Conocidas

- Los porcentajes no pueden ser negativos
- La validación de "Otro" vive en `wizard_presupuesto_screen.dart` (0–100%)
- El servicio `CalculadoraFinanzas` es singleton, instancia global única

## Mejoras Futuras

- [ ] Guardar histórico de cambios en parámetros
- [ ] Exportar presupuesto a PDF con desglose financiero
- [ ] Comparar múltiples escenarios financieros
- [ ] Aplicar descuentos por volumen
- [ ] Diferentes tasas de IVA por regiones
