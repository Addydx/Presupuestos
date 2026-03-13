import 'package:flutter/material.dart';
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
      _nombre = _nombreController.text;
      _categoria = _categoriaController.text;
      _unidad = _unidadController.text;
      _cantidad = double.parse(_cantidadController.text);
      _precioUnitario = double.parse(_precioUnitarioController.text);

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
      (double.tryParse(_cantidadController.text) ?? 0) *
      (double.tryParse(_precioUnitarioController.text) ?? 0);

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
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
                readOnly: widget.materialCatalogo != null,
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
                  if (value == null || value.isEmpty) {
                    return 'La categoría es requerida';
                  }
                  return null;
                },
                readOnly: widget.materialCatalogo != null,
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
                  if (value == null || value.isEmpty) {
                    return 'La unidad es requerida';
                  }
                  return null;
                },
                readOnly: widget.materialCatalogo != null,
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
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Número inválido';
                        }
                        return null;
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
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Total calculado
              Card(
                color: Colors.blue.shade50,
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
                          color: Colors.blue,
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
                  color: Colors.orange.shade50,
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
