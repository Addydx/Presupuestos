import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/Presupuesto/gasto.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:hive/hive.dart';

class NewPresupuestoScrren extends StatefulWidget {
  final String proyectoId;
  const NewPresupuestoScrren({super.key, required this.proyectoId});

  @override
  State<NewPresupuestoScrren> createState() => _NewPresupuestoScrrenState();
}

class _NewPresupuestoScrrenState extends State<NewPresupuestoScrren> {
  final _formKey = GlobalKey<FormState>();
  final _nombrePresupuestoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final List<Map<String, dynamic>> _gastos = [];
  final _gastoNombreController = TextEditingController();
  final _gastoMontoController = TextEditingController();

  @override
  void dispose() {
    _nombrePresupuestoController.dispose();
    _descripcionController.dispose();
    _gastoNombreController.dispose();
    _gastoMontoController.dispose();
    super.dispose();
  }

  void _agregarGasto() {
    if (_gastoNombreController.text.isNotEmpty &&
        _gastoMontoController.text.isNotEmpty) {
      setState(() {
        _gastos.add({
          'nombre': _gastoNombreController.text,
          'monto': double.tryParse(_gastoMontoController.text) ?? 0.0,
        });
        _gastoNombreController.clear();
        _gastoMontoController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Presupuesto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo nombre del presupuesto
              const Text(
                'Nombre del presupuesto',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombrePresupuestoController,
                decoration: InputDecoration(
                  hintText: 'Ej: Presupuesto para remodelación',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre para el presupuesto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo descripción
              const Text(
                'Descripción',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ej: Detalles sobre el presupuesto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 20),

              // Lista de gastos
              const Text(
                'Gastos',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _gastos.length,
                itemBuilder: (context, index) {
                  final gasto = _gastos[index];
                  return ListTile(
                    title: Text(gasto['nombre']),
                    subtitle: Text(
                      'Monto: ${gasto['monto'].toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _gastos.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Campos para agregar un nuevo gasto
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gastoNombreController,
                      decoration: InputDecoration(
                        hintText: 'Nombre del gasto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _gastoMontoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Monto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: _agregarGasto,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final presupuesto = Presupuesto(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nombre: _nombrePresupuestoController.text.trim(),
                        descripcion: _descripcionController.text.trim(),
                        gastos: List<Map<String, dynamic>>.from(_gastos),
                        proyectoId:
                            widget.proyectoId, //se tiene que realcionar con un proyecto existente
                      );
                      final box = Hive.box<Presupuesto>('presupuestos');
                      await box.put(presupuesto.id, presupuesto);

                      Navigator.pop(context, presupuesto);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar Presupuesto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
