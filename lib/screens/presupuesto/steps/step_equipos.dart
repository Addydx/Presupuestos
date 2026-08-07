import 'package:flutter/material.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/screens/equipos/equipo_form_sheet.dart';
import 'package:presupuesto_app/services/equipos_service.dart';

class StepEquipos extends StatefulWidget {
  final EquiposService equiposService;

  /// Se llama cada vez que cambia la lista, para que el wizard (dueño de
  /// la barra de total persistente y del autoguardado) se entere aunque
  /// el cambio haya ocurrido dentro de una hoja modal.
  final VoidCallback? onCambio;

  const StepEquipos({super.key, required this.equiposService, this.onCambio});

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
    // Diferido: si esto se dispara desde initState() (primera carga), el
    // wizard todavía puede estar construyéndose y no admite un setState
    // síncrono en ese momento.
    final onCambio = widget.onCambio;
    if (onCambio != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onCambio();
      });
    }
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
                onPressed: () async {
                  await widget.equiposService.eliminarEquipo(id);
                  if (!context.mounted) return;
                  _cargarEquipos();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Equipo eliminado')),
                  );
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  void _abrirAgregarEquipo() {
    mostrarHojaEquipo(
      context: context,
      equiposService: widget.equiposService,
      onCambio: _cargarEquipos,
    );
  }

  void _abrirEditarEquipo(Equipo equipo) {
    mostrarHojaEquipo(
      context: context,
      equiposService: widget.equiposService,
      equipoEditando: equipo,
      onCambio: _cargarEquipos,
    );
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
                      color: AppColors.gray500,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sin equipos agregados',
                      style: TextStyle(fontSize: 16, color: AppColors.gray700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Agrega equipos rentados para tu presupuesto',
                      style: TextStyle(fontSize: 14, color: AppColors.gray700),
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
                        // El total ya no vive apilado en `trailing` junto al
                        // botón de menú (ese patrón desbordaba la altura
                        // fija del ListTile). Sigue el mismo patrón que la
                        // lista de materiales: total dentro del subtítulo,
                        // trailing = solo el botón de menú.
                        isThreeLine: true,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.yellowSoft,
                          child: const Icon(
                            Icons.construction,
                            color: AppColors.black,
                          ),
                        ),
                        title: Text(equipo.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${equipo.dias} días × ${MonedaUtils.formatear(equipo.costoPorDia)}/día',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Total: ${MonedaUtils.formatear(equipo.total)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') {
                              _abrirEditarEquipo(equipo);
                            }
                            if (value == 'eliminar') {
                              _eliminarEquipo(equipo.id);
                            }
                          },
                          itemBuilder:
                              (context) => const [
                                PopupMenuItem(
                                  value: 'editar',
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem(
                                  value: 'eliminar',
                                  child: Text(
                                    'Eliminar',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                          offset: const Offset(-100, 0),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Total general
                Card(
                  color: AppColors.gray100,
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
                          MonedaUtils.formatear(totalGeneral),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
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
