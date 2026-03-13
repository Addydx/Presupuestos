import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';

class FinanzasScreen extends StatefulWidget {
  /// Totales de otros módulos para calcular costo directo
  final double totalMateriales;
  final double totalManoObra;
  final double totalEquipos;

  /// Callback para retornar los datos de finanzas editados
  final Function(Finanzas) onFinanzasChanged;

  /// Datos iniciales (opcional)
  final Finanzas? finanzasInicial;

  const FinanzasScreen({
    super.key,
    required this.totalMateriales,
    required this.totalManoObra,
    required this.totalEquipos,
    required this.onFinanzasChanged,
    this.finanzasInicial,
  });

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  late TextEditingController _imprevistoController;
  late TextEditingController _utilidadController;
  late bool _aplicarIVA;

  final CalculadoraFinanzas _calculadora = CalculadoraFinanzas();

  late Map<String, double> _resultados;

  @override
  void initState() {
    super.initState();
    // Inicializar valores
    _aplicarIVA = widget.finanzasInicial?.aplicarIVA ?? true;
    _imprevistoController = TextEditingController(
      text: (widget.finanzasInicial?.porcentajeImprevistos ?? 5.0).toString(),
    );
    _utilidadController = TextEditingController(
      text: (widget.finanzasInicial?.porcentajeUtilidad ?? 20.0).toString(),
    );

    // Calcular valores iniciales después de que el frame se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calcularValores();
    });
  }

  @override
  void dispose() {
    _imprevistoController.dispose();
    _utilidadController.dispose();
    super.dispose();
  }

  /// Calcula y actualiza todos los valores financieros
  void _calcularValores() {
    final porcentajeImprevistos =
        double.tryParse(_imprevistoController.text) ?? 0;
    final porcentajeUtilidad = double.tryParse(_utilidadController.text) ?? 0;

    final finanzas = Finanzas(
      porcentajeImprevistos: porcentajeImprevistos,
      porcentajeUtilidad: porcentajeUtilidad,
      aplicarIVA: _aplicarIVA,
    );

    setState(() {
      _resultados = _calculadora.calcularTodo(
        totalMateriales: widget.totalMateriales,
        totalManoObra: widget.totalManoObra,
        totalEquipos: widget.totalEquipos,
        finanzas: finanzas,
      );
    });

    // Notificar cambios (diferido para evitar setState durante build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFinanzasChanged(finanzas);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================ COSTO DIRECTO ================
          const SizedBox(height: 8),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Costo Directo',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildFilaValor('Materiales:', widget.totalMateriales),
                  _buildFilaValor('Mano de Obra:', widget.totalManoObra),
                  _buildFilaValor('Equipos:', widget.totalEquipos),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Divider(color: Colors.grey.shade400, height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildFilaValor(
                      'Total Costo Directo:',
                      _resultados['costoDirecto'] ?? 0,
                      esMarcado: true,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================ PARÁMETROS EDITABLES ================
          const SizedBox(height: 12),
          const Text(
            'Parámetros Financieros',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Campo: Porcentaje Imprevistos
          TextFormField(
            controller: _imprevistoController,
            decoration: InputDecoration(
              labelText: 'Porcentaje Imprevistos (%)',
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              suffixIcon: const Icon(Icons.percent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calcularValores(),
          ),
          const SizedBox(height: 8),

          // Campo: Porcentaje Utilidad
          TextFormField(
            controller: _utilidadController,
            decoration: InputDecoration(
              labelText: 'Porcentaje Utilidad (%)',
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              suffixIcon: const Icon(Icons.percent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _calcularValores(),
          ),
          const SizedBox(height: 12),

          // Switch: Aplicar IVA
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aplicar IVA (16%)',
                    style: TextStyle(fontSize: 13),
                  ),
                  Switch(
                    value: _aplicarIVA,
                    onChanged: (value) {
                      setState(() {
                        _aplicarIVA = value;
                      });
                      _calcularValores();
                    },
                  ),
                ],
              ),
            ),
          ),

          // ================ RESULTADOS ================
          const SizedBox(height: 12),
          const Text(
            'Cálculos Financieros',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Card con todos los resultados
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildFilaValor(
                    'Imprevistos:',
                    _resultados['imprevistos'] ?? 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Divider(color: Colors.grey.shade300, height: 1),
                  ),
                  _buildFilaValor('Subtotal:', _resultados['subtotal'] ?? 0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Divider(color: Colors.grey.shade300, height: 1),
                  ),
                  _buildFilaValor('Utilidad:', _resultados['utilidad'] ?? 0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Divider(color: Colors.grey.shade300, height: 1),
                  ),
                  _buildFilaValor(
                    'Precio Final:',
                    _resultados['precioFinal'] ?? 0,
                    esMarcado: true,
                  ),
                  if (_aplicarIVA) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Divider(color: Colors.grey.shade300, height: 1),
                    ),
                    _buildFilaValor('IVA (16%):', _resultados['iva'] ?? 0),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Colors.grey.shade400, height: 2),
                  ),
                  _buildFilaValor(
                    'TOTAL FINAL:',
                    _resultados['totalFinal'] ?? 0,
                    esMarcado: true,
                    esTotal: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Resumen de porcentajes
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de Márgenes',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildResumenFila(
                    'Costo Directo:',
                    _resultados['costoDirecto'] ?? 0,
                    _resultados['totalFinal'] ?? 1,
                  ),
                  _buildResumenFila(
                    'Margen Imprevistos:',
                    _resultados['imprevistos'] ?? 0,
                    _resultados['totalFinal'] ?? 1,
                  ),
                  _buildResumenFila(
                    'Margen Utilidad:',
                    _resultados['utilidad'] ?? 0,
                    _resultados['totalFinal'] ?? 1,
                  ),
                  if (_aplicarIVA)
                    _buildResumenFila(
                      'Margen IVA:',
                      _resultados['iva'] ?? 0,
                      _resultados['totalFinal'] ?? 1,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Widget para mostrar una fila de valor (etiqueta + cantidad)
  Widget _buildFilaValor(
    String label,
    double valor, {
    bool esMarcado = false,
    bool esTotal = false,
  }) {
    final fontSize = esTotal ? 14.0 : 12.0;
    final fontWeight = esTotal ? FontWeight.bold : FontWeight.w500;
    final color =
        esTotal
            ? Colors.green.shade700
            : (esMarcado ? Colors.blue.shade700 : Colors.black87);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
        Text(
          _calculadora.formatoMoneda(valor),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Widget para mostrar un ítem de resumen con porcentaje
  Widget _buildResumenFila(String label, double monto, double total) {
    final porcentaje = total > 0 ? ((monto / total) * 100) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            '${porcentaje.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
