import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/screens/equipos/agregar_editar_equipo_screen.dart';
import 'package:presupuesto_app/services/equipos_service.dart';

class StepEquipos extends StatefulWidget {
  final EquiposService equiposService;

  const StepEquipos({super.key, required this.equiposService});

  @override
  State<StepEquipos> createState() => _StepEquiposState();
}

class _StepEquiposState extends State<StepEquipos> {
  late List<Equipo> equipos;

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  void _cargarEquipos() {
    setState(() {
      equipos = widget.equiposService.obtenerEquipos();
    });
  }

  void _eliminarEquipo(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Equipo'),
            content: const Text('¿Está seguro que desea eliminar este equipo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  widget.equiposService.eliminarEquipo(id);
                  _cargarEquipos();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Equipo eliminado')),
                  );
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _abrirAgregarEquipo() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AgregarEditarEquipoScreen(
              equiposService: widget.equiposService,
            ),
      ),
    );
    if (resultado == true) {
      _cargarEquipos();
    }
  }

  void _abrirEditarEquipo(Equipo equipo) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AgregarEditarEquipoScreen(
              equiposService: widget.equiposService,
              equipoEditando: equipo,
            ),
      ),
    );
    if (resultado == true) {
      _cargarEquipos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalGeneral = widget.equiposService.calcularTotalEquipos();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón para agregar
          ElevatedButton.icon(
            onPressed: _abrirAgregarEquipo,
            icon: const Icon(Icons.add),
            label: const Text('Agregar Equipo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 8),

          // Lista de equipos
          if (equipos.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.construction,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sin equipos agregados',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Agrega equipos rentados para tu presupuesto',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: equipos.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final equipo = equipos[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: const Icon(
                            Icons.construction,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(equipo.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${equipo.dias} días × \$${equipo.costoPorDia.toStringAsFixed(2)}/día',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${equipo.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      onTap: () => _abrirEditarEquipo(equipo),
                                      child: const Text('Editar'),
                                    ),
                                    PopupMenuItem(
                                      onTap: () => _eliminarEquipo(equipo.id),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                              offset: const Offset(-100, 0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Total general
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Equipos:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${totalGeneral.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
