import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/services/equipos_service.dart';

class AgregarEditarEquipoScreen extends StatefulWidget {
  final EquiposService equiposService;
  final Equipo? equipoEditando;

  const AgregarEditarEquipoScreen({
    super.key,
    required this.equiposService,
    this.equipoEditando,
  });

  @override
  State<AgregarEditarEquipoScreen> createState() =>
      _AgregarEditarEquipoScreenState();
}

class _AgregarEditarEquipoScreenState extends State<AgregarEditarEquipoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late double _costoPorDia;
  late int _dias;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.equipoEditando != null) {
      _nombre = widget.equipoEditando!.nombre;
      _costoPorDia = widget.equipoEditando!.costoPorDia;
      _dias = widget.equipoEditando!.dias;
      _total = widget.equipoEditando!.total;
    } else {
      _nombre = '';
      _costoPorDia = 0.0;
      _dias = 1;
      _total = 0.0;
    }
  }

  void _calcularTotal() {
    setState(() {
      _total = _costoPorDia * _dias;
    });
  }

  void _guardarEquipo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _calcularTotal();

      final equipo = Equipo(
        id: widget.equipoEditando?.id,
        nombre: _nombre,
        costoPorDia: _costoPorDia,
        dias: _dias,
      );

      if (widget.equipoEditando != null) {
        await widget.equiposService.actualizarEquipo(equipo);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Equipo actualizado')));
      } else {
        await widget.equiposService.agregarEquipo(equipo);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Equipo agregado')));
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.equipoEditando != null ? 'Editar Equipo' : 'Agregar Equipo',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del equipo
              TextFormField(
                initialValue: _nombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Equipo',
                  hintText: 'Ej: Grúa, Excavadora, Andamio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.construction),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre del equipo';
                  }
                  return null;
                },
                onSaved: (value) => _nombre = value!,
                onChanged: (value) => _nombre = value,
              ),
              const SizedBox(height: 16),

              // Costo por día
              TextFormField(
                initialValue:
                    widget.equipoEditando != null
                        ? _costoPorDia.toString()
                        : '',
                decoration: const InputDecoration(
                  labelText: 'Costo por Día',
                  hintText: 'Ej: 100.50',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el costo por día';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Ingrese un número válido mayor a 0';
                  }
                  return null;
                },
                onSaved: (value) => _costoPorDia = double.parse(value!),
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    _costoPorDia = parsed;
                    _calcularTotal();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Número de días
              TextFormField(
                initialValue:
                    widget.equipoEditando != null ? _dias.toString() : '1',
                decoration: const InputDecoration(
                  labelText: 'Número de Días',
                  hintText: 'Ej: 5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el número de días';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Ingrese un número válido mayor a 0';
                  }
                  return null;
                },
                onSaved: (value) => _dias = int.parse(value!),
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    _dias = parsed;
                    _calcularTotal();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Cálculo automático
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cálculo Automático:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_dias días × \$$_costoPorDia',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        '\$${_total.toStringAsFixed(2)}',
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
              const SizedBox(height: 24),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardarEquipo,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.equipoEditando != null
                        ? 'Actualizar Equipo'
                        : 'Guardar Equipo',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón cancelar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
