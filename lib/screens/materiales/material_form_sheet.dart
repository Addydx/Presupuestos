import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/advertencia_monto_alto.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

/// Muestra la hoja para agregar o editar un material del presupuesto.
///
/// Al agregar (no al editar) ofrece "Guardar y agregar otro" para cargar
/// varios materiales sin volver a abrir la hoja cada vez.
Future<void> mostrarHojaMaterial({
  required BuildContext context,
  required MaterialesService materialesService,
  required VoidCallback onCambio,
  MaterialPresupuesto? materialEditando,
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
        (context) => _MaterialFormSheet(
          materialesService: materialesService,
          onCambio: onCambio,
          materialEditando: materialEditando,
        ),
  );
}

class _MaterialFormSheet extends StatefulWidget {
  final MaterialesService materialesService;
  final VoidCallback onCambio;
  final MaterialPresupuesto? materialEditando;

  const _MaterialFormSheet({
    required this.materialesService,
    required this.onCambio,
    this.materialEditando,
  });

  @override
  State<_MaterialFormSheet> createState() => _MaterialFormSheetState();
}

class _MaterialFormSheetState extends State<_MaterialFormSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _unidadController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioController = TextEditingController();

  final _focoNombre = FocusNode();
  final _focoCategoria = FocusNode();
  final _focoUnidad = FocusNode();
  final _focoCantidad = FocusNode();
  final _focoPrecio = FocusNode();

  final _keyNombre = GlobalKey<FormFieldState<String>>();
  final _keyCategoria = GlobalKey<FormFieldState<String>>();
  final _keyUnidad = GlobalKey<FormFieldState<String>>();
  final _keyCantidad = GlobalKey<FormFieldState<String>>();
  final _keyPrecio = GlobalKey<FormFieldState<String>>();

  bool _precioSospechoso = false;

  bool get _esEdicion => widget.materialEditando != null;

  /// Un material que vino del catálogo mantiene nombre/categoría/unidad
  /// bloqueados, igual que en la pantalla completa anterior.
  bool get _camposBasicosBloqueados =>
      _esEdicion && !widget.materialEditando!.esPersonalizado;

  @override
  void initState() {
    super.initState();
    final m = widget.materialEditando;
    if (m != null) {
      _nombreController.text = m.nombre;
      _categoriaController.text = m.categoria;
      _unidadController.text = m.unidad;
      _cantidadController.text = m.cantidad.toString();
      _precioController.text = MonedaInputFormatter.textoInicial(
        m.precioUnitario,
      );
    } else {
      _cantidadController.text = '1';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focoNombre.requestFocus();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _unidadController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    _focoNombre.dispose();
    _focoCategoria.dispose();
    _focoUnidad.dispose();
    _focoCantidad.dispose();
    _focoPrecio.dispose();
    super.dispose();
  }

  double get _totalCalculado {
    final cantidad = MonedaUtils.aDouble(_cantidadController.text) ?? 0;
    final precio = MonedaInputFormatter.valorDe(_precioController.text);
    return cantidad * precio;
  }

  Future<void> _guardar({required bool agregarOtro}) async {
    final valido = validarPasoYEnfocarError(
      formKey: _formKey,
      camposEnOrden: [
        (_keyNombre, _focoNombre),
        (_keyCategoria, _focoCategoria),
        (_keyUnidad, _focoUnidad),
        (_keyCantidad, _focoCantidad),
        (_keyPrecio, _focoPrecio),
      ],
    );
    if (!valido) return;

    final nombre = _nombreController.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final material = MaterialPresupuesto(
      id: widget.materialEditando?.id,
      nombre: nombre,
      categoria: _categoriaController.text.trim().replaceAll(
        RegExp(r'\s+'),
        ' ',
      ),
      unidad: _unidadController.text.trim().replaceAll(RegExp(r'\s+'), ' '),
      cantidad: MonedaUtils.aDouble(_cantidadController.text) ?? 0,
      precioUnitario: MonedaInputFormatter.valorDe(_precioController.text),
      esPersonalizado: widget.materialEditando?.esPersonalizado ?? true,
      materialCatalogoId: widget.materialEditando?.materialCatalogoId,
    );

    if (_esEdicion) {
      await widget.materialesService.actualizarMaterialPresupuesto(material);
    } else {
      await widget.materialesService.agregarMaterialPresupuesto(material);
    }
    widget.onCambio();

    if (!mounted) return;

    if (agregarOtro && !_esEdicion) {
      _formKey.currentState!.reset();
      _nombreController.clear();
      _categoriaController.clear();
      _unidadController.clear();
      _cantidadController.text = '1';
      _precioController.clear();
      setState(() => _precioSospechoso = false);
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
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
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
                    _esEdicion ? 'Editar material' : 'Agregar material',
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
                    siguienteFoco: _focoCategoria,
                    readOnly: _camposBasicosBloqueados,
                    decoration: InputDecoration(
                      labelText: 'Nombre del material',
                      hintText: 'Ej: Cemento, Arena, Ladrillo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.label),
                    ),
                    validator:
                        (v) => Validadores.requerido(
                          v,
                          campo: 'el nombre',
                          maximo: 60,
                        ),
                  ),
                  const SizedBox(height: 14),
                  CampoValidado(
                    fieldKey: _keyCategoria,
                    focusNode: _focoCategoria,
                    controller: _categoriaController,
                    siguienteFoco: _focoUnidad,
                    readOnly: _camposBasicosBloqueados,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      hintText: 'Ej: Estructural, Acabados, Pintura',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    validator:
                        (v) => Validadores.requerido(
                          v,
                          campo: 'la categoría',
                          maximo: 40,
                        ),
                  ),
                  const SizedBox(height: 14),
                  CampoValidado(
                    fieldKey: _keyUnidad,
                    focusNode: _focoUnidad,
                    controller: _unidadController,
                    siguienteFoco: _focoCantidad,
                    readOnly: _camposBasicosBloqueados,
                    decoration: InputDecoration(
                      labelText: 'Unidad',
                      hintText: 'Ej: kg, litro, m², pieza',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.straighten),
                    ),
                    validator:
                        (v) => Validadores.requerido(
                          v,
                          campo: 'la unidad',
                          maximo: 15,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CampoValidado(
                          fieldKey: _keyCantidad,
                          focusNode: _focoCantidad,
                          controller: _cantidadController,
                          siguienteFoco: _focoPrecio,
                          decoration: InputDecoration(
                            labelText: 'Cantidad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.numbers),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          validator:
                              (v) => Validadores.numeroPositivo(
                                v,
                                campo: 'la cantidad',
                              ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CampoValidado(
                          fieldKey: _keyPrecio,
                          focusNode: _focoPrecio,
                          controller: _precioController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Precio/Unidad',
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
                                campo: 'el precio por unidad',
                              ),
                          onChanged: (v) {
                            setState(() {
                              _precioSospechoso =
                                  Validadores.esSospechosamenteAlto(
                                    MonedaInputFormatter.valorDe(v),
                                  );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  AdvertenciaMontoAlto(visible: _precioSospechoso),
                  const SizedBox(height: 12),
                  Card(
                    color: AppColors.gray100,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total del material:',
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
