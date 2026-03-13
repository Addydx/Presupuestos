# Módulo de Finanzas

## Descripción General

El módulo de Finanzas proporciona herramientas para calcular y gestionar los aspectos financieros de un presupuesto de construcción. Incluye cálculos automáticos de imprevistos, utilidad, IVA y generación de totales finales.

## Estructura de Archivos

```
lib/
├── models/presupuesto/
│   └── finanzas.dart                 # Modelo de datos Hive
├── services/
│   └── calculadora_finanzas.dart     # Servicio singleton de cálculos
├── screens/finanzas/
│   └── finanzas_screen.dart          # Pantalla principal
└── screens/presupuesto/steps/
    └── step_finanzas.dart             # Integración con wizard
```

## Modelo: Finanzas

```dart
@HiveType(typeId: 6)
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

## Pantalla: FinanzasScreen

### Propiedades

```dart
FinanzasScreen(
  // Totales de otros módulos
  totalMateriales: 5000,
  totalManoObra: 3000,
  totalEquipos: 2000,
  
  // Callback cuando cambien los parámetros
  onFinanzasChanged: (finanzas) {
    print('Nuevos parámetros: $finanzas');
  },
  
  // Valores iniciales (opcional)
  finanzasInicial: Finanzas(
    porcentajeImprevistos: 5,
    porcentajeUtilidad: 20,
    aplicarIVA: true,
  ),
)
```

### Características

✅ **Mostrar Costos Directos:**
- Desglose de materiales, mano de obra y equipos
- Total de costo directo

✅ **Campos Editables:**
- Porcentaje de imprevistos (con spinner)
- Porcentaje de utilidad (con spinner)

✅ **Switch Opcional:**
- Activar/desactivar IVA

✅ **Cálculos en Tiempo Real:**
- Se actualizan automáticamente cuando el usuario modifica los campos

✅ **Resultados Visuales:**
- Imprevistos, Subtotal, Utilidad, Precio Final, IVA, Total Final
- Cards con colores distintivos para fácil lectura

✅ **Resumen de Márgenes:**
- Muestra el porcentaje que representa cada componente del total

### Uso Básico

```dart
void _abrirFinanzas() async {
  final resultado = await Navigator.push<Finanzas>(
    context,
    MaterialPageRoute(
      builder: (context) => FinanzasScreen(
        totalMateriales: 5000,
        totalManoObra: 3000,
        totalEquipos: 2000,
        onFinanzasChanged: (finanzas) {
          // Hacer algo con los parámetros
          guardarFinanzas(finanzas);
        },
      ),
    ),
  );
  
  if (resultado != null) {
    print('Finanzas guardadas: $resultado');
  }
}
```

## Integración con el Wizard

El módulo se integra automáticamente en el **Paso 5** del wizard de presupuestos.

### En `wizard_presupuesto_screen.dart`

```dart
Step(
  title: const Text('Finanzas'),
  content: StepFinanzas(
    totalMateriales: _materialesService.calcularTotalMateriales(),
    totalManoObra: _manoObra?.costo ?? 0,
    totalEquipos: _equiposService.calcularTotalEquipos(),
    onFinanzasChanged: (finanzas) {
      setState(() {
        _finanzas = finanzas;
      });
    },
    finanzasInicial: _finanzas,
  ),
  isActive: _currentStep >= 4,
)
```

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

## Casos de Uso

### Caso 1: Cliente Exento de IVA
```dart
final finanzas = Finanzas(
  porcentajeImprevistos: 5,
  porcentajeUtilidad: 20,
  aplicarIVA: false,  // ← Sin IVA
);
```

### Caso 2: Presupuesto Agresivo (baja ganancia)
```dart
final finanzas = Finanzas(
  porcentajeImprevistos: 2,  // Mínimo riesgo
  porcentajeUtilidad: 10,    // Ganancia baja
  aplicarIVA: true,
);
```

### Caso 3: Presupuesto Conservador (alta ganancia)
```dart
final finanzas = Finanzas(
  porcentajeImprevistos: 10,  // Mayor cobertura
  porcentajeUtilidad: 30,     // Ganancia alta
  aplicarIVA: true,
);
```

## Testing

Para verificar los cálculos, ejecuta:

```bash
dart EJEMPLOS_FINANZAS.dart
```

Esto muestra 6 ejemplos diferentes de cálculos financieros.

## Notas Importantes

✅ **El TotalFinal es el precio que se facturaría al cliente**

✅ **Los cálculos se pueden actualizar en tiempo real moviendo los sliders**

✅ **El modelo se guarda automáticamente en Hive cuando se avanza al siguiente paso**

✅ **El IVA solo se aplica si la opción está habilitada**

✅ **Los márgenes se calculan como porcentajes del total final**

## Constantes

```dart
static const double IVA_RATE = 0.16;  // 16% IVA colombiano
```

## Limitaciones Conocidas

- Los porcentajes no pueden ser negativos
- Lee validación en `FinanzasScreen`
- El servicio es singleton, instancia global única

## Mejoras Futuras

- [ ] Guardar histórico de cambios en parámetros
- [ ] Exportar presupuesto a PDF con desglose financiero
- [ ] Comparar múltiples escenarios financieros
- [ ] Aplicar descuentos por volumen
- [ ] Diferentes tasas de IVA por regiones
