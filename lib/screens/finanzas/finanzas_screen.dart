import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
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

  /// Permite al wizard validar este paso antes de avanzar.
  final GlobalKey<FormState>? formKey;

  const FinanzasScreen({
    super.key,
    required this.totalMateriales,
    required this.totalManoObra,
    required this.totalEquipos,
    required this.onFinanzasChanged,
    this.finanzasInicial,
    this.formKey,
  });

  @override
  State<FinanzasScreen> createState() => FinanzasScreenState();
}

class FinanzasScreenState extends State<FinanzasScreen> {
  late final GlobalKey<FormState> _formKey;
  late TextEditingController _imprevistoController;
  late TextEditingController _utilidadController;
  late bool _aplicarIVA;
  Timer? _debounceNotificacion;

  final FocusNode _focoImprevistos = FocusNode();
  final FocusNode _focoUtilidad = FocusNode();
  final GlobalKey<FormFieldState<String>> _campoImprevistosKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _campoUtilidadKey = GlobalKey();

  double _ultimoImprevistos = -1;
  double _ultimoUtilidad = -1;
  bool _ultimoIva = false;

  final CalculadoraFinanzas _calculadora = CalculadoraFinanzas();

  late Map<String, double> _resultados;

  /// Lista ordenada de campos para "scroll + enfoque al primer error".
  List<CampoRef> get camposEnOrden => [
    (_campoImprevistosKey, _focoImprevistos),
    (_campoUtilidadKey, _focoUtilidad),
  ];

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _aplicarIVA = widget.finanzasInicial?.aplicarIVA ?? true;
    _imprevistoController = TextEditingController(
      text: (widget.finanzasInicial?.porcentajeImprevistos ?? 5.0).toString(),
    );
    _utilidadController = TextEditingController(
      text: (widget.finanzasInicial?.porcentajeUtilidad ?? 20.0).toString(),
    );

    // Calcular y notificar un único estado inicial (los defaults son
    // siempre válidos, así que esto nunca dispara la ruta de error).
    _calcularValores(notificarPadre: true);
  }

  @override
  void didUpdateWidget(covariant FinanzasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Los totales de materiales/mano de obra/equipos vienen del wizard y
    // cambian cuando el usuario vuelve a un paso anterior a editarlos. Sin
    // esto, "Costo Directo" se queda con el valor calculado la primera vez
    // que se entró a este paso, aunque las líneas individuales sí se
    // actualicen (vienen directo de los props, no de este estado).
    if (oldWidget.totalMateriales != widget.totalMateriales ||
        oldWidget.totalManoObra != widget.totalManoObra ||
        oldWidget.totalEquipos != widget.totalEquipos) {
      _calcularValores(notificarPadre: false);
    }
  }

  @override
  void dispose() {
    _debounceNotificacion?.cancel();
    _imprevistoController.dispose();
    _utilidadController.dispose();
    _focoImprevistos.dispose();
    _focoUtilidad.dispose();
    super.dispose();
  }

  /// Calcula y actualiza los valores financieros a partir de los campos.
  ///
  /// Si algún porcentaje es inválido (vacío, no numérico o fuera de
  /// 0–100), NO recalcula ni notifica al padre: el resultado mostrado se
  /// congela en el último valor válido y el campo muestra su propio
  /// mensaje de error. Antes, un valor inválido se convertía
  /// silenciosamente en 0, lo que podía dejar un presupuesto con 0% de
  /// utilidad sin que el usuario lo notara.
  void _calcularValores({bool notificarPadre = true}) {
    final porcentajeImprevistos = MonedaUtils.aDouble(
      _imprevistoController.text,
    );
    final porcentajeUtilidad = MonedaUtils.aDouble(_utilidadController.text);

    final imprevistosValido =
        porcentajeImprevistos != null &&
        porcentajeImprevistos >= 0 &&
        porcentajeImprevistos <= 100;
    final utilidadValido =
        porcentajeUtilidad != null &&
        porcentajeUtilidad >= 0 &&
        porcentajeUtilidad <= 100;

    if (!imprevistosValido || !utilidadValido) {
      return;
    }

    final finanzas = Finanzas(
      porcentajeImprevistos: porcentajeImprevistos,
      porcentajeUtilidad: porcentajeUtilidad,
      aplicarIVA: _aplicarIVA,
    );

    final nuevosResultados = _calculadora.calcularTodo(
      totalMateriales: widget.totalMateriales,
      totalManoObra: widget.totalManoObra,
      totalEquipos: widget.totalEquipos,
      finanzas: finanzas,
    );

    if (mounted) {
      setState(() {
        _resultados = nuevosResultados;
      });
    }

    if (!notificarPadre) return;

    final bool huboCambio =
        _ultimoImprevistos != porcentajeImprevistos ||
        _ultimoUtilidad != porcentajeUtilidad ||
        _ultimoIva != _aplicarIVA;

    if (!huboCambio) return;

    _ultimoImprevistos = porcentajeImprevistos;
    _ultimoUtilidad = porcentajeUtilidad;
    _ultimoIva = _aplicarIVA;

    _debounceNotificacion?.cancel();
    _debounceNotificacion = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      widget.onFinanzasChanged(finanzas);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================ COSTO DIRECTO ================
            const SizedBox(height: 8),
            Card(
              color: AppColors.gray100,
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
                      child: Divider(color: AppColors.gray500, height: 1),
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
            CampoValidado(
              fieldKey: _campoImprevistosKey,
              focusNode: _focoImprevistos,
              controller: _imprevistoController,
              siguienteFoco: _focoUtilidad,
              decoration: InputDecoration(
                labelText: 'Porcentaje Imprevistos (%)',
                isDense: true,
                contentPadding: const EdgeInsets.all(8),
                suffixIcon: const Icon(Icons.percent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator:
                  (value) =>
                      Validadores.porcentaje(value, campo: 'Imprevistos'),
              onChanged: (_) => _calcularValores(),
            ),
            const SizedBox(height: 8),

            // Campo: Porcentaje Utilidad
            CampoValidado(
              fieldKey: _campoUtilidadKey,
              focusNode: _focoUtilidad,
              controller: _utilidadController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Porcentaje Utilidad (%)',
                isDense: true,
                contentPadding: const EdgeInsets.all(8),
                suffixIcon: const Icon(Icons.percent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator:
                  (value) => Validadores.porcentaje(value, campo: 'Utilidad'),
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
              color: AppColors.white,
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
                      child: Divider(color: AppColors.gray300, height: 1),
                    ),
                    _buildFilaValor('Subtotal:', _resultados['subtotal'] ?? 0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Divider(color: AppColors.gray300, height: 1),
                    ),
                    _buildFilaValor('Utilidad:', _resultados['utilidad'] ?? 0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Divider(color: AppColors.gray300, height: 1),
                    ),
                    _buildFilaValor(
                      'Precio Final:',
                      _resultados['precioFinal'] ?? 0,
                      esMarcado: true,
                    ),
                    if (_aplicarIVA) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Divider(color: AppColors.gray300, height: 1),
                      ),
                      _buildFilaValor('IVA (16%):', _resultados['iva'] ?? 0),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: AppColors.gray500, height: 2),
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
              color: AppColors.gray100,
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
            ? AppColors.success
            : (esMarcado ? AppColors.info : AppColors.black);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              MonedaUtils.formatear(valor),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color,
              ),
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '${porcentaje.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
