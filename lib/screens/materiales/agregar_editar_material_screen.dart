import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/material_catalogo.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

class AgregarEditarMaterialScreen extends StatefulWidget {
  final MaterialesService materialesService;
  final MaterialPresupuesto? materialEditando;
  final MaterialCatalogo? materialCatalogo;

  const AgregarEditarMaterialScreen({
    super.key,
    required this.materialesService,
    this.materialEditando,
    this.materialCatalogo,
  });

  @override
  State<AgregarEditarMaterialScreen> createState() =>
      _AgregarEditarMaterialScreenState();
}

class _AgregarEditarMaterialScreenState
    extends State<AgregarEditarMaterialScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _nombre;
  late String _categoria;
  late String _unidad;
  late double _cantidad;
  late double _precioUnitario;
  bool _esPersonalizado = false;

  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _unidadController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioUnitarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  void _inicializarDatos() {
    if (widget.materialCatalogo != null) {
      // Desde catálogo
      _nombreController.text = widget.materialCatalogo!.nombre;
      _categoriaController.text = widget.materialCatalogo!.categoria;
      _unidadController.text = widget.materialCatalogo!.unidad;
      _precioUnitarioController.text =
          widget.materialCatalogo!.precioReferencia.toString();
      _cantidadController.text = '1';
      _esPersonalizado = false;
    } else if (widget.materialEditando != null) {
      // Edición
      _nombreController.text = widget.materialEditando!.nombre;
      _categoriaController.text = widget.materialEditando!.categoria;
      _unidadController.text = widget.materialEditando!.unidad;
      _cantidadController.text = widget.materialEditando!.cantidad.toString();
      _precioUnitarioController.text =
          widget.materialEditando!.precioUnitario.toString();
      _esPersonalizado = widget.materialEditando!.esPersonalizado;
    } else {
      // Nuevo material personalizado
      _cantidadController.text = '1';
      _esPersonalizado = true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _unidadController.dispose();
    _cantidadController.dispose();
    _precioUnitarioController.dispose();
    super.dispose();
  }

  void _guardarMaterial() {
    if (_formKey.currentState!.validate()) {
      _nombre = _normalizarTexto(_nombreController.text);
      _categoria = _normalizarTexto(_categoriaController.text);
      _unidad = _normalizarTexto(_unidadController.text);
      _cantidad = _parseDecimal(_cantidadController.text)!;
      _precioUnitario = _parseDecimal(_precioUnitarioController.text)!;

      final materialPresupuesto = MaterialPresupuesto(
        id: widget.materialEditando?.id,
        nombre: _nombre,
        categoria: _categoria,
        unidad: _unidad,
        cantidad: _cantidad,
        precioUnitario: _precioUnitario,
        esPersonalizado: _esPersonalizado,
        materialCatalogoId: widget.materialCatalogo?.id,
      );

      Navigator.pop(context, materialPresupuesto);
    }
  }

  double get _totalCalculado =>
      (_parseDecimal(_cantidadController.text) ?? 0) *
      (_parseDecimal(_precioUnitarioController.text) ?? 0);

  String _normalizarTexto(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  double? _parseDecimal(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim());
  }

  String? _validarTextoGeneral(
    String? value, {
    required String nombreCampo,
    required int maximo,
  }) {
    final texto = _normalizarTexto(value ?? '');

    if (texto.isEmpty) {
      return 'El campo $nombreCampo es requerido';
    }
    if (texto.length < 2) {
      return 'El campo $nombreCampo debe tener al menos 2 caracteres';
    }
    if (texto.length > maximo) {
      return 'El campo $nombreCampo no puede superar $maximo caracteres';
    }

    return null;
  }

  String? _validarNumero(
    String? value, {
    required String nombreCampo,
    required bool permitirCero,
    double? maximo,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo $nombreCampo es requerido';
    }

    final numero = _parseDecimal(value);
    if (numero == null) {
      return 'Ingrese un número válido en $nombreCampo';
    }
    if (!permitirCero && numero <= 0) {
      return 'El campo $nombreCampo debe ser mayor a 0';
    }
    if (permitirCero && numero < 0) {
      return 'El campo $nombreCampo no puede ser negativo';
    }
    if (maximo != null && numero > maximo) {
      return 'El campo $nombreCampo supera el máximo permitido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.materialEditando != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Material' : 'Agregar Material'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo: Nombre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Material',
                  hintText: 'Ej: Cemento, Arena, Ladrillo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (value) {
                  return _validarTextoGeneral(
                    value,
                    nombreCampo: 'nombre',
                    maximo: 60,
                  );
                },
                readOnly: widget.materialCatalogo != null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Campo: Categoría
              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  hintText: 'Ej: Estructural, Acabados, Pintura',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                validator: (value) {
                  return _validarTextoGeneral(
                    value,
                    nombreCampo: 'categoría',
                    maximo: 40,
                  );
                },
                readOnly: widget.materialCatalogo != null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Campo: Unidad
              TextFormField(
                controller: _unidadController,
                decoration: InputDecoration(
                  labelText: 'Unidad',
                  hintText: 'Ej: kg, litro, m², pieza',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.straighten),
                ),
                validator: (value) {
                  return _validarTextoGeneral(
                    value,
                    nombreCampo: 'unidad',
                    maximo: 15,
                  );
                },
                readOnly: widget.materialCatalogo != null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Row: Cantidad y Precio
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _cantidadController,
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
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        return _validarNumero(
                          value,
                          nombreCampo: 'cantidad',
                          permitirCero: false,
                          maximo: 1000000,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _precioUnitarioController,
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        return _validarNumero(
                          value,
                          nombreCampo: 'precio por unidad',
                          permitirCero: false,
                          maximo: 1000000000,
                        );
                      },
                    ),
                  ),
                ],
              ),
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
                        '\$${_totalCalculado.toStringAsFixed(2)}',
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

              // Checkbox: Personalizado
              if (!esEdicion || widget.materialEditando!.esPersonalizado)
                Card(
                  color: AppColors.yellowSoft,
                  child: CheckboxListTile(
                    title: const Text('Material Personalizado'),
                    subtitle: const Text(
                      'Este material no está en el catálogo',
                    ),
                    value: _esPersonalizado,
                    onChanged:
                        widget.materialCatalogo == null
                            ? (value) {
                              setState(() {
                                _esPersonalizado = value ?? false;
                              });
                            }
                            : null,
                  ),
                ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _guardarMaterial,
                      icon: const Icon(Icons.check),
                      label: Text(esEdicion ? 'Actualizar' : 'Guardar'),
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
