import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/advertencia_monto_alto.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/services/equipos_service.dart';

/// Muestra la hoja para agregar o editar un equipo rentado del
/// presupuesto. Al agregar (no al editar) ofrece "Guardar y agregar
/// otro" para cargar varios equipos sin volver a abrir la hoja.
Future<void> mostrarHojaEquipo({
  required BuildContext context,
  required EquiposService equiposService,
  required VoidCallback onCambio,
  Equipo? equipoEditando,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder:
        (context) => _EquipoFormSheet(
          equiposService: equiposService,
          onCambio: onCambio,
          equipoEditando: equipoEditando,
        ),
  );
}

class _EquipoFormSheet extends StatefulWidget {
  final EquiposService equiposService;
  final VoidCallback onCambio;
  final Equipo? equipoEditando;

  const _EquipoFormSheet({
    required this.equiposService,
    required this.onCambio,
    this.equipoEditando,
  });

  @override
  State<_EquipoFormSheet> createState() => _EquipoFormSheetState();
}

class _EquipoFormSheetState extends State<_EquipoFormSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _costoPorDiaController = TextEditingController();
  final _diasController = TextEditingController();

  final _focoNombre = FocusNode();
  final _focoCostoPorDia = FocusNode();
  final _focoDias = FocusNode();

  final _keyNombre = GlobalKey<FormFieldState<String>>();
  final _keyCostoPorDia = GlobalKey<FormFieldState<String>>();
  final _keyDias = GlobalKey<FormFieldState<String>>();

  bool _costoSospechoso = false;

  bool get _esEdicion => widget.equipoEditando != null;

  @override
  void initState() {
    super.initState();
    final e = widget.equipoEditando;
    if (e != null) {
      _nombreController.text = e.nombre;
      _costoPorDiaController.text = MonedaInputFormatter.textoInicial(
        e.costoPorDia,
      );
      _diasController.text = e.dias.toString();
    } else {
      _diasController.text = '1';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focoNombre.requestFocus();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _costoPorDiaController.dispose();
    _diasController.dispose();
    _focoNombre.dispose();
    _focoCostoPorDia.dispose();
    _focoDias.dispose();
    super.dispose();
  }

  double get _totalCalculado {
    final dias = int.tryParse(_diasController.text.trim()) ?? 0;
    final costo = MonedaInputFormatter.valorDe(_costoPorDiaController.text);
    return dias * costo;
  }

  Future<void> _guardar({required bool agregarOtro}) async {
    final valido = validarPasoYEnfocarError(
      formKey: _formKey,
      camposEnOrden: [
        (_keyNombre, _focoNombre),
        (_keyCostoPorDia, _focoCostoPorDia),
        (_keyDias, _focoDias),
      ],
    );
    if (!valido) return;

    final nombre = _nombreController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final equipo = Equipo(
      id: widget.equipoEditando?.id,
      nombre: nombre,
      costoPorDia: MonedaInputFormatter.valorDe(_costoPorDiaController.text),
      dias: int.parse(_diasController.text.trim()),
    );

    if (_esEdicion) {
      await widget.equiposService.actualizarEquipo(equipo);
    } else {
      await widget.equiposService.agregarEquipo(equipo);
    }
    widget.onCambio();

    if (!mounted) return;

    if (agregarOtro && !_esEdicion) {
      _formKey.currentState!.reset();
      _nombreController.clear();
      _costoPorDiaController.clear();
      _diasController.text = '1';
      setState(() => _costoSospechoso = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('"$nombre" agregado. Sigue con el siguiente.'),
            duration: const Duration(seconds: 2),
          ),
        );
      _focoNombre.requestFocus();
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.gray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    _esEdicion ? 'Editar equipo' : 'Agregar equipo',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CampoValidado(
                    fieldKey: _keyNombre,
                    focusNode: _focoNombre,
                    controller: _nombreController,
                    siguienteFoco: _focoCostoPorDia,
                    decoration: InputDecoration(
                      labelText: 'Nombre del equipo',
                      hintText: 'Ej: Grúa, Excavadora, Andamio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.construction),
                    ),
                    maxLength: 80,
                    validator:
                        (v) => Validadores.requerido(
                          v,
                          campo: 'el nombre del equipo',
                          maximo: 80,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CampoValidado(
                          fieldKey: _keyCostoPorDia,
                          focusNode: _focoCostoPorDia,
                          controller: _costoPorDiaController,
                          siguienteFoco: _focoDias,
                          decoration: InputDecoration(
                            labelText: 'Costo por Día',
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
                              (v) => Validadores.numeroPositivo(
                                v,
                                campo: 'el costo por día',
                              ),
                          onChanged: (v) {
                            setState(() {
                              _costoSospechoso =
                                  Validadores.esSospechosamenteAlto(
                                    MonedaInputFormatter.valorDe(v),
                                  );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CampoValidado(
                          fieldKey: _keyDias,
                          focusNode: _focoDias,
                          controller: _diasController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Número de Días',
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
                              (v) => Validadores.enteroPositivo(
                                v,
                                campo: 'el número de días',
                              ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  AdvertenciaMontoAlto(visible: _costoSospechoso),
                  const SizedBox(height: 12),
                  Card(
                    color: AppColors.gray100,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cálculo automático:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            MonedaUtils.formatear(_totalCalculado),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                          onPressed: () => _guardar(agregarOtro: false),
                          child: Text(_esEdicion ? 'Actualizar' : 'Guardar'),
                        ),
                      ),
                    ],
                  ),
                  if (!_esEdicion) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: () => _guardar(agregarOtro: true),
                        icon: const Icon(Icons.add),
                        label: const Text('Guardar y agregar otro'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
