import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/advertencia_monto_alto.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';

class StepManoObra extends StatefulWidget {
  final GlobalKey<FormState>? formKey;

  /// `null` cuando el usuario marca "sin mano de obra" para este
  /// presupuesto.
  final void Function(ManoObra?)? onSaved;
  final ManoObra? initialData;

  const StepManoObra({super.key, this.formKey, this.onSaved, this.initialData});

  @override
  State<StepManoObra> createState() => StepManoObraState();
}

class StepManoObraState extends State<StepManoObra> {
  late GlobalKey<FormState> _formKey;

  late bool _sinManoObra;
  late TipoPago _tipoPago;
  late String? _observaciones;

  final _rolController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _diasController = TextEditingController();
  final _costoPorDiaController = TextEditingController();
  final _montoContratoController = TextEditingController();
  final _observacionesController = TextEditingController();

  final _focoRol = FocusNode();
  final _focoCantidad = FocusNode();
  final _focoDias = FocusNode();
  final _focoCostoPorDia = FocusNode();
  final _focoMontoContrato = FocusNode();
  final _focoObservaciones = FocusNode();

  final _campoCantidadKey = GlobalKey<FormFieldState<String>>();
  final _campoDiasKey = GlobalKey<FormFieldState<String>>();
  final _campoCostoPorDiaKey = GlobalKey<FormFieldState<String>>();
  final _campoMontoContratoKey = GlobalKey<FormFieldState<String>>();

  bool _costoPorDiaSospechoso = false;
  bool _montoContratoSospechoso = false;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _inicializarDatos();
  }

  void _inicializarDatos() {
    final datos = widget.initialData;
    _sinManoObra = false;
    if (datos != null) {
      _tipoPago = datos.tipoPago;
      _rolController.text = datos.rol ?? '';
      _cantidadController.text = datos.cantidadPersonas?.toString() ?? '';
      _diasController.text = datos.diasEstimados?.toString() ?? '';
      _costoPorDiaController.text = MonedaInputFormatter.textoInicial(
        datos.costoPorDia ?? 0,
      );
      _montoContratoController.text = MonedaInputFormatter.textoInicial(
        datos.montoContrato ?? 0,
      );
      _observaciones = datos.observaciones;
      _observacionesController.text = datos.observaciones ?? '';
    } else {
      _tipoPago = TipoPago.porDia;
      _observaciones = null;
    }
  }

  @override
  void dispose() {
    _rolController.dispose();
    _cantidadController.dispose();
    _diasController.dispose();
    _costoPorDiaController.dispose();
    _montoContratoController.dispose();
    _observacionesController.dispose();
    _focoRol.dispose();
    _focoCantidad.dispose();
    _focoDias.dispose();
    _focoCostoPorDia.dispose();
    _focoMontoContrato.dispose();
    _focoObservaciones.dispose();
    super.dispose();
  }

  List<CampoRef> get _camposEnOrden {
    if (_tipoPago == TipoPago.porDia) {
      return [
        (_campoCantidadKey, _focoCantidad),
        (_campoDiasKey, _focoDias),
        (_campoCostoPorDiaKey, _focoCostoPorDia),
      ];
    }
    return [(_campoMontoContratoKey, _focoMontoContrato)];
  }

  /// Valida y guarda el paso. Devuelve `true` si se puede avanzar.
  bool saveForm() {
    if (_sinManoObra) {
      widget.onSaved?.call(null);
      return true;
    }

    final valido = validarPasoYEnfocarError(
      formKey: _formKey,
      camposEnOrden: _camposEnOrden,
    );
    if (!valido) return false;

    _guardar();
    return true;
  }

  void _guardar() {
    final rolTexto = _rolController.text.trim();
    final manoObra = ManoObra(
      tipoPago: _tipoPago,
      rol: rolTexto.isEmpty ? null : rolTexto,
      cantidadPersonas: int.tryParse(_cantidadController.text.trim()),
      diasEstimados: int.tryParse(_diasController.text.trim()),
      costoPorDia: MonedaInputFormatter.valorDe(_costoPorDiaController.text),
      montoContrato: MonedaInputFormatter.valorDe(
        _montoContratoController.text,
      ),
      observaciones: _observaciones,
    );
    widget.onSaved?.call(manoObra);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Permite dejar el paso vacío: un presupuesto de solo
          // materiales es un caso de uso válido.
          Card(
            color: _sinManoObra ? AppColors.yellowSoft : AppColors.white,
            child: SwitchListTile(
              value: _sinManoObra,
              onChanged: (value) {
                setState(() => _sinManoObra = value);
              },
              title: const Text(
                'Este presupuesto no incluye mano de obra',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _sinManoObra
                    ? 'No se registrará personal ni costo de mano de obra. Puedes activarlo de nuevo cuando quieras.'
                    : 'Actívalo si este presupuesto es solo de materiales o equipos.',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          if (!_sinManoObra) ...[
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown: Tipo de Pago
                  DropdownButtonFormField<TipoPago>(
                    initialValue: _tipoPago,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Pago',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.payment),
                    ),
                    items:
                        TipoPago.values.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(
                              tipo == TipoPago.porDia
                                  ? 'Por Día'
                                  : 'Por Contrato',
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _tipoPago = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campos para "Por Día"
                  if (_tipoPago == TipoPago.porDia) ...[
                    // Campo: Rol (opcional, "Personal" por defecto)
                    TextFormField(
                      controller: _rolController,
                      focusNode: _focoRol,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Rol (opcional)',
                        hintText: 'Ej: Albañil, Chalán — por defecto "Personal"',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      onFieldSubmitted: (_) => _focoCantidad.requestFocus(),
                    ),
                    const SizedBox(height: 16),

                    // Campo: Cantidad de Personas
                    CampoValidado(
                      fieldKey: _campoCantidadKey,
                      focusNode: _focoCantidad,
                      controller: _cantidadController,
                      siguienteFoco: _focoDias,
                      decoration: InputDecoration(
                        labelText: 'Cantidad de Personas',
                        hintText: 'Ej: 2',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.group),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator:
                          (value) => Validadores.enteroPositivo(
                            value,
                            campo: 'la cantidad de personas',
                          ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Campo: Días Estimados
                    CampoValidado(
                      fieldKey: _campoDiasKey,
                      focusNode: _focoDias,
                      controller: _diasController,
                      siguienteFoco: _focoCostoPorDia,
                      decoration: InputDecoration(
                        labelText: 'Días Estimados',
                        hintText: 'Ej: 10',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator:
                          (value) => Validadores.enteroPositivo(
                            value,
                            campo: 'los días estimados',
                          ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Campo: Costo por Día
                    CampoValidado(
                      fieldKey: _campoCostoPorDiaKey,
                      focusNode: _focoCostoPorDia,
                      controller: _costoPorDiaController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Costo por Día',
                        hintText: 'Ej: 150.50',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const [MonedaInputFormatter()],
                      validator:
                          (value) => Validadores.numeroPositivo(
                            value,
                            campo: 'el costo por día',
                          ),
                      onChanged: (value) {
                        setState(() {
                          _costoPorDiaSospechoso = Validadores.esSospechosamenteAlto(
                            MonedaInputFormatter.valorDe(value),
                          );
                        });
                      },
                    ),
                    AdvertenciaMontoAlto(visible: _costoPorDiaSospechoso),
                    const SizedBox(height: 20),

                    // Resumen para "Por Día"
                    _buildResumenPorDia(),
                  ],

                  // Campos para "Por Contrato"
                  if (_tipoPago == TipoPago.porContrato) ...[
                    // Campo: Monto del Contrato
                    CampoValidado(
                      fieldKey: _campoMontoContratoKey,
                      focusNode: _focoMontoContrato,
                      controller: _montoContratoController,
                      siguienteFoco: _focoObservaciones,
                      decoration: InputDecoration(
                        labelText: 'Monto del Contrato',
                        hintText: 'Ej: 1,500.00',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const [MonedaInputFormatter()],
                      validator:
                          (value) => Validadores.numeroPositivo(
                            value,
                            campo: 'el monto del contrato',
                          ),
                      onChanged: (value) {
                        setState(() {
                          _montoContratoSospechoso = Validadores.esSospechosamenteAlto(
                            MonedaInputFormatter.valorDe(value),
                          );
                        });
                      },
                    ),
                    AdvertenciaMontoAlto(visible: _montoContratoSospechoso),
                    const SizedBox(height: 16),

                    // Campo: Observaciones
                    TextFormField(
                      controller: _observacionesController,
                      focusNode: _focoObservaciones,
                      decoration: InputDecoration(
                        labelText: 'Observaciones (opcional)',
                        hintText: 'Ej: Incluye materiales',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.notes),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        _observaciones = value.trim().isEmpty ? null : value.trim();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Resumen para "Por Contrato"
                    _buildResumenPorContrato(),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResumenPorDia() {
    final cantPersonas = int.tryParse(_cantidadController.text) ?? 0;
    final diasEst = int.tryParse(_diasController.text) ?? 0;
    final costoDia = MonedaInputFormatter.valorDe(_costoPorDiaController.text);

    final totalPersonasDias = cantPersonas * diasEst;
    final totalCosto = totalPersonasDias * costoDia;

    return Card(
      color: AppColors.gray100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen por Día',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildResumenRow(
              'Personas × Días:',
              '$cantPersonas × $diasEst = $totalPersonasDias jornadas',
            ),
            const SizedBox(height: 8),
            _buildResumenRow(
              'Costo por jornada:',
              MonedaUtils.formatear(costoDia),
            ),
            const Divider(),
            _buildResumenRow(
              'Total:',
              MonedaUtils.formatear(totalCosto),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenPorContrato() {
    final monto = MonedaInputFormatter.valorDe(_montoContratoController.text);

    return Card(
      color: AppColors.gray100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen por Contrato',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildResumenRow(
              'Monto Total:',
              MonedaUtils.formatear(monto),
              isTotal: true,
            ),
            if (_observaciones?.isNotEmpty ?? false)
              Column(
                children: [
                  const Divider(),
                  const Text(
                    'Observaciones:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _observaciones ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 14 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 14 : 13,
            color: isTotal ? AppColors.info : AppColors.black,
          ),
        ),
      ],
    );
  }
}
