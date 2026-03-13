import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/screens/materiales/agregar_editar_material_screen.dart';
import 'package:presupuesto_app/screens/materiales/catalogo_materiales_screen.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

class MaterialesPresupuestoScreen extends StatefulWidget {
  final MaterialesService materialesService;

  const MaterialesPresupuestoScreen({
    super.key,
    required this.materialesService,
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
                onPressed: () {
                  widget.materialesService.eliminarMaterialPresupuesto(id);
                  _cargarMateriales();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Material eliminado')),
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

  void _abrirAgregarMaterial() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AgregarEditarMaterialScreen(
              materialesService: widget.materialesService,
            ),
      ),
    );
    if (resultado == true) {
      _cargarMateriales();
    }
  }

  void _abrirEditarMaterial(MaterialPresupuesto material) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AgregarEditarMaterialScreen(
              materialesService: widget.materialesService,
              materialEditando: material,
            ),
      ),
    );
    if (resultado == true) {
      _cargarMateriales();
    }
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
                    backgroundColor: Colors.blue,
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
                    Icon(
                      Icons.inventory_2,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sin materiales agregados',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Agrega materiales para tu presupuesto',
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
                  itemCount: materiales.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final material = materiales[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            material.nombre[0].toUpperCase(),
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        title: Text(material.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${material.cantidad} ${material.unidad} × \$${material.precioUnitario.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (material.esPersonalizado)
                              Chip(
                                label: const Text('Personalizado'),
                                visualDensity: VisualDensity.compact,
                                side: const BorderSide(color: Colors.orange),
                                labelStyle: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange,
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${material.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      onTap:
                                          () => _abrirEditarMaterial(material),
                                      child: const Text('Editar'),
                                    ),
                                    PopupMenuItem(
                                      onTap:
                                          () => _eliminarMaterial(material.id),
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
                  color: Colors.blue.shade50,
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
                          '\$${totalGeneral.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
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
