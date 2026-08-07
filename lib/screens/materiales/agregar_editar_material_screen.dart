import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/core/utils/validadores.dart';
import 'package:presupuesto_app/core/widgets/advertencia_monto_alto.dart';
import 'package:presupuesto_app/core/widgets/campo_validado.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/material_catalogo.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

/// Confirma cantidad y precio de un material tomado del catálogo antes de
/// agregarlo al presupuesto. Nombre, categoría y unidad vienen fijos del
/// catálogo.
class AgregarEditarMaterialScreen extends StatefulWidget {
  final MaterialesService materialesService;
  final MaterialCatalogo materialCatalogo;

  const AgregarEditarMaterialScreen({
    super.key,
    required this.materialesService,
    required this.materialCatalogo,
  });

  @override
  State<AgregarEditarMaterialScreen> createState() =>
      _AgregarEditarMaterialScreenState();
}

class _AgregarEditarMaterialScreenState
    extends State<AgregarEditarMaterialScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cantidadController = TextEditingController(text: '1');
  final _precioUnitarioController = TextEditingController();

  final _focoCantidad = FocusNode();
  final _focoPrecio = FocusNode();
  final _keyCantidad = GlobalKey<FormFieldState<String>>();
  final _keyPrecio = GlobalKey<FormFieldState<String>>();

  bool _precioSospechoso = false;

  @override
  void initState() {
    super.initState();
    _precioUnitarioController.text = MonedaInputFormatter.textoInicial(
      widget.materialCatalogo.precioReferencia,
    );
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _precioUnitarioController.dispose();
    _focoCantidad.dispose();
    _focoPrecio.dispose();
    super.dispose();
  }

  double get _totalCalculado {
    final cantidad = MonedaUtils.aDouble(_cantidadController.text) ?? 0;
    final precio = MonedaInputFormatter.valorDe(_precioUnitarioController.text);
    return cantidad * precio;
  }

  void _guardarMaterial() {
    final valido = validarPasoYEnfocarError(
      formKey: _formKey,
      camposEnOrden: [(_keyCantidad, _focoCantidad), (_keyPrecio, _focoPrecio)],
    );
    if (!valido) return;

    final materialPresupuesto = MaterialPresupuesto(
      nombre: widget.materialCatalogo.nombre,
      categoria: widget.materialCatalogo.categoria,
      unidad: widget.materialCatalogo.unidad,
      cantidad: MonedaUtils.aDouble(_cantidadController.text) ?? 0,
      precioUnitario: MonedaInputFormatter.valorDe(
        _precioUnitarioController.text,
      ),
      esPersonalizado: false,
      materialCatalogoId: widget.materialCatalogo.id,
    );

    Navigator.pop(context, materialPresupuesto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Material')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppColors.gray100,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.yellowSoft,
                    child: Text(
                      widget.materialCatalogo.nombre[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.black),
                    ),
                  ),
                  title: Text(widget.materialCatalogo.nombre),
                  subtitle: Text(
                    '${widget.materialCatalogo.categoria} · ${widget.materialCatalogo.unidad}',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Row: Cantidad y Precio
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
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator:
                          (v) =>
                              Validadores.numeroPositivo(v, campo: 'la cantidad'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CampoValidado(
                      fieldKey: _keyPrecio,
                      focusNode: _focoPrecio,
                      controller: _precioUnitarioController,
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
                          _precioSospechoso = Validadores.esSospechosamenteAlto(
                            MonedaInputFormatter.valorDe(v),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
              AdvertenciaMontoAlto(visible: _precioSospechoso),
              const SizedBox(height: 20),

              // Total calculado
              Card(
                color: AppColors.gray100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total del Material:',
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
              const SizedBox(height: 24),

              // Botones
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
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: _guardarMaterial,
                      icon: const Icon(Icons.check),
                      label: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
