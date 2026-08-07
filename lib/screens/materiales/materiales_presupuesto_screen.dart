import 'package:flutter/material.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/screens/materiales/catalogo_materiales_screen.dart';
import 'package:presupuesto_app/screens/materiales/material_form_sheet.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

class MaterialesPresupuestoScreen extends StatefulWidget {
  final MaterialesService materialesService;

  /// Se llama cada vez que cambia la lista, para que el wizard (dueño de
  /// la barra de total persistente y del autoguardado) se entere aunque
  /// el cambio haya ocurrido dentro de una hoja modal.
  final VoidCallback? onCambio;

  const MaterialesPresupuestoScreen({
    super.key,
    required this.materialesService,
    this.onCambio,
  });

  @override
  State<MaterialesPresupuestoScreen> createState() =>
      _MaterialesPresupuestoScreenState();
}

class _MaterialesPresupuestoScreenState
    extends State<MaterialesPresupuestoScreen> {
  late List<MaterialPresupuesto> materiales;

  @override
  void initState() {
    super.initState();
    _cargarMateriales();
  }

  void _cargarMateriales() {
    setState(() {
      materiales = widget.materialesService.obtenerMaterialesPresupuesto();
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

  void _eliminarMaterial(String id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Material'),
            content: const Text(
              '¿Está seguro que desea eliminar este material?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await widget.materialesService.eliminarMaterialPresupuesto(
                    id,
                  );
                  if (!context.mounted) return;
                  _cargarMateriales();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Material eliminado')),
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

  void _abrirAgregarMaterial() {
    mostrarHojaMaterial(
      context: context,
      materialesService: widget.materialesService,
      onCambio: _cargarMateriales,
    );
  }

  void _abrirEditarMaterial(MaterialPresupuesto material) {
    mostrarHojaMaterial(
      context: context,
      materialesService: widget.materialesService,
      materialEditando: material,
      onCambio: _cargarMateriales,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalGeneral = widget.materialesService.calcularTotalMateriales();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botones de acciones
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _abrirAgregarMaterial,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Material'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final resultado = await Navigator.push<MaterialPresupuesto>(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CatalogoMaterialesScreen(
                              materialesService: widget.materialesService,
                            ),
                      ),
                    );
                    if (resultado != null) {
                      await widget.materialesService.agregarMaterialPresupuesto(
                        resultado,
                      );
                      _cargarMateriales();
                    }
                  },
                  icon: const Icon(Icons.library_books),
                  label: const Text('Catálogo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lista de materiales
          if (materiales.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2, size: 64, color: AppColors.gray500),
                    const SizedBox(height: 16),
                    Text(
                      'Sin materiales agregados',
                      style: TextStyle(fontSize: 16, color: AppColors.gray700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Agrega materiales para tu presupuesto',
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
                  itemCount: materiales.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final material = materiales[index];
                    return Card(
                      child: ListTile(
                        isThreeLine: material.esPersonalizado,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.yellowSoft,
                          child: Text(
                            material.nombre[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.black),
                          ),
                        ),
                        title: Text(material.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${material.cantidad} ${material.unidad} × ${MonedaUtils.formatear(material.precioUnitario)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Total: ${MonedaUtils.formatear(material.total)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (material.esPersonalizado)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Chip(
                                  label: const Text('Personalizado'),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: AppColors.yellowSoft,
                                  side: BorderSide.none,
                                  labelStyle: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'editar') {
                              _abrirEditarMaterial(material);
                            }
                            if (value == 'eliminar') {
                              _eliminarMaterial(material.id);
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
                          'Total:',
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
                            color: AppColors.info,
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
