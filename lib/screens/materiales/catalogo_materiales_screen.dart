import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/material_catalogo.dart';
import 'package:presupuesto_app/screens/materiales/agregar_editar_material_screen.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

class CatalogoMaterialesScreen extends StatefulWidget {
  final MaterialesService materialesService;

  const CatalogoMaterialesScreen({super.key, required this.materialesService});

  @override
  State<CatalogoMaterialesScreen> createState() =>
      _CatalogoMaterialesScreenState();
}

class _CatalogoMaterialesScreenState extends State<CatalogoMaterialesScreen> {
  late List<MaterialCatalogo> materiales;
  late List<MaterialCatalogo> materialesFiltrados;
  final _searchController = TextEditingController();
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarMateriales();
    _searchController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargarMateriales() {
    setState(() {
      materiales = widget.materialesService.obtenerCatalogos();
      materialesFiltrados = materiales;
    });
  }

  void _filtrar() {
    setState(() {
      final termoBusqueda = _searchController.text;

      if (termoBusqueda.isEmpty && _categoriaSeleccionada == null) {
        materialesFiltrados = materiales;
      } else {
        materialesFiltrados =
            materiales.where((material) {
              final coincideTexto =
                  termoBusqueda.isEmpty ||
                  material.nombre.toLowerCase().contains(
                    termoBusqueda.toLowerCase(),
                  ) ||
                  material.categoria.toLowerCase().contains(
                    termoBusqueda.toLowerCase(),
                  );

              final coincideCategoria =
                  _categoriaSeleccionada == null ||
                  material.categoria == _categoriaSeleccionada;

              return coincideTexto && coincideCategoria;
            }).toList();
      }
    });
  }

  void _agregarDelCatalogo(MaterialCatalogo materialCatalogo) async {
    final resultado = await Navigator.push<MaterialPresupuesto>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AgregarEditarMaterialScreen(
              materialesService: widget.materialesService,
              materialCatalogo: materialCatalogo,
            ),
      ),
    );

    if (resultado != null) {
      Navigator.pop(context, resultado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = widget.materialesService.obtenerCategorias().toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Materiales'), elevation: 0),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar material...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Filtro por categoría
          if (categorias.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Todas'),
                      selected: _categoriaSeleccionada == null,
                      onSelected: (selected) {
                        setState(() {
                          _categoriaSeleccionada = null;
                          _filtrar();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...categorias.map((categoria) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(categoria),
                          selected: _categoriaSeleccionada == categoria,
                          onSelected: (selected) {
                            setState(() {
                              _categoriaSeleccionada =
                                  selected ? categoria : null;
                              _filtrar();
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Lista de materiales
          Expanded(
            child:
                materialesFiltrados.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin resultados',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: materialesFiltrados.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final material = materialesFiltrados[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Text(
                                material.nombre[0].toUpperCase(),
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                            title: Text(material.nombre),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  material.categoria,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Precio ref: \$${material.precioReferencia.toStringAsFixed(2)} / ${material.unidad}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _agregarDelCatalogo(material),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Agregar'),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
