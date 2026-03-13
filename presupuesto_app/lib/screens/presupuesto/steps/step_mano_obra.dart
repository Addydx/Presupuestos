import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';

class StepManoObra extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final Function(ManoObra)? onSaved;
  final ManoObra? initialData;

  const StepManoObra({super.key, this.formKey, this.onSaved, this.initialData});

  @override
  State<StepManoObra> createState() => _StepManoObraState();
}

class _StepManoObraState extends State<StepManoObra> {
  late GlobalKey<FormState> _formKey;

  late TipoPago _tipoPago;
  late String? _rol;
  late int? _cantidadPersonas;
  late int? _diasEstimados;
  late double? _costoPorDia;
  late double? _montoContrato;
  late String? _observaciones;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _inicializarDatos();
  }

  void _inicializarDatos() {
    if (widget.initialData != null) {
      _tipoPago = widget.initialData!.tipoPago;
      _rol = widget.initialData!.rol;
      _cantidadPersonas = widget.initialData!.cantidadPersonas;
      _diasEstimados = widget.initialData!.diasEstimados;
      _costoPorDia = widget.initialData!.costoPorDia;
      _montoContrato = widget.initialData!.montoContrato;
      _observaciones = widget.initialData!.observaciones;
    } else {
      _tipoPago = TipoPago.porDia;
      _rol = null;
      _cantidadPersonas = null;
      _diasEstimados = null;
      _costoPorDia = null;
      _montoContrato = null;
      _observaciones = null;
    }
  }

  String? _validarCampoRequerido(String? value, String nombreCampo) {
    if (value == null || value.isEmpty) {
      return 'El campo $nombreCampo es requerido';
    }
    return null;
  }

  String? _validarNumeroPositivo(String? value, String nombreCampo) {
    if (value == null || value.isEmpty) {
      return 'El campo $nombreCampo es requerido';
    }
    final numero = num.tryParse(value);
    if (numero == null) {
      return 'Ingrese un número válido en $nombreCampo';
    }
    if (numero <= 0) {
      return '$nombreCampo debe ser mayor a 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown: Tipo de Pago
            DropdownButtonFormField<TipoPago>(
              value: _tipoPago,
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
                        tipo == TipoPago.porDia ? 'Por Día' : 'Por Contrato',
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tipoPago = value;
                  });
                }
              },
              validator:
                  (value) =>
                      value == null ? 'Seleccione un tipo de pago' : null,
            ),
            const SizedBox(height: 20),

            // Campos para "Por Día"
            if (_tipoPago == TipoPago.porDia) ...[
              // Campo: Rol
              TextFormField(
                initialValue: _rol,
                decoration: InputDecoration(
                  labelText: 'Rol',
                  hintText: 'Ej: Albañil, Chalán',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) => _validarCampoRequerido(value, 'Rol'),
                onSaved: (value) => _rol = value,
              ),
              const SizedBox(height: 16),

              // Campo: Cantidad de Personas
              TextFormField(
                initialValue: _cantidadPersonas?.toString(),
                decoration: InputDecoration(
                  labelText: 'Cantidad de Personas',
                  hintText: 'Ej: 2',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.group),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        _validarNumeroPositivo(value, 'Cantidad de personas'),
                onSaved: (value) => _cantidadPersonas = int.parse(value!),
              ),
              const SizedBox(height: 16),

              // Campo: Días Estimados
              TextFormField(
                initialValue: _diasEstimados?.toString(),
                decoration: InputDecoration(
                  labelText: 'Días Estimados',
                  hintText: 'Ej: 10',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) => _validarNumeroPositivo(value, 'Días estimados'),
                onSaved: (value) => _diasEstimados = int.parse(value!),
              ),
              const SizedBox(height: 16),

              // Campo: Costo por Día
              TextFormField(
                initialValue: _costoPorDia?.toString(),
                decoration: InputDecoration(
                  labelText: 'Costo por Día',
                  hintText: 'Ej: 150.50',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator:
                    (value) => _validarNumeroPositivo(value, 'Costo por día'),
                onSaved: (value) => _costoPorDia = double.parse(value!),
              ),
              const SizedBox(height: 20),

              // Resumen para "Por Día"
              _buildResumenPorDia(),
            ],

            // Campos para "Por Contrato"
            if (_tipoPago == TipoPago.porContrato) ...[
              // Campo: Monto del Contrato
              TextFormField(
                initialValue: _montoContrato?.toString(),
                decoration: InputDecoration(
                  labelText: 'Monto del Contrato',
                  hintText: 'Ej: 1500.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator:
                    (value) =>
                        _validarNumeroPositivo(value, 'Monto del contrato'),
                onSaved: (value) => _montoContrato = double.parse(value!),
              ),
              const SizedBox(height: 16),

              // Campo: Observaciones
              TextFormField(
                initialValue: _observaciones,
                decoration: InputDecoration(
                  labelText: 'Observaciones',
                  hintText: 'Ej: Incluye materiales',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.notes),
                ),
                maxLines: 3,
                onSaved:
                    (value) =>
                        _observaciones = value?.isEmpty ?? true ? null : value,
              ),
              const SizedBox(height: 20),

              // Resumen para "Por Contrato"
              _buildResumenPorContrato(),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenPorDia() {
    final cantPersonas = int.tryParse(_cantidadPersonas?.toString() ?? '') ?? 0;
    final diasEst = int.tryParse(_diasEstimados?.toString() ?? '') ?? 0;
    final costoDia = double.tryParse(_costoPorDia?.toString() ?? '') ?? 0.0;

    final totalPersonasDias = cantPersonas * diasEst;
    final totalCosto = totalPersonasDias * costoDia;

    return Card(
      color: Colors.blue.shade50,
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
              '\$${costoDia.toStringAsFixed(2)}',
            ),
            const Divider(),
            _buildResumenRow(
              'Total:',
              '\$${totalCosto.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenPorContrato() {
    final monto = double.tryParse(_montoContrato?.toString() ?? '') ?? 0.0;

    return Card(
      color: Colors.green.shade50,
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
              '\$${monto.toStringAsFixed(2)}',
              isTotal: true,
            ),
            if ((_observaciones?.isNotEmpty ?? false))
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
            color: isTotal ? Colors.blue : Colors.black87,
          ),
        ),
      ],
    );
  }
}
