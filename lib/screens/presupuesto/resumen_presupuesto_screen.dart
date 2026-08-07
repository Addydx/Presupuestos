import 'package:flutter/material.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';
import 'package:presupuesto_app/core/utils/moneda_utils.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_equipos.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_finanzas.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_mano_obra.dart';
import 'package:presupuesto_app/screens/presupuesto/widgets/seccion_materiales.dart';
import 'package:presupuesto_app/screens/presupuesto/wizard_presupuesto_screen.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';
import 'package:presupuesto_app/services/pdf_service.dart';

class ResumenPresupuestoScreen extends StatefulWidget {
  final List<MaterialPresupuesto>? materiales;
  final List<Equipo>? equipos;
  final List<ManoObra>? manoObra;
  final Finanzas? finanzas;
  final String? titulo;
  final DateTime? fecha;
  final Presupuesto? presupuesto;

  const ResumenPresupuestoScreen({
    super.key,
    this.materiales,
    this.equipos,
    this.manoObra,
    this.finanzas,
    this.titulo,
    this.fecha,
    this.presupuesto,
  });

  @override
  State<ResumenPresupuestoScreen> createState() =>
      _ResumenPresupuestoScreenState();
}

class _ResumenPresupuestoScreenState extends State<ResumenPresupuestoScreen> {
  bool _exportando = false;
  Presupuesto? _presupuestoActual;

  @override
  void initState() {
    super.initState();
    _presupuestoActual = widget.presupuesto;
  }

  // Accesos cortos a los datos del widget padre
  List<MaterialPresupuesto> get _materiales =>
      _presupuestoActual?.materiales ?? widget.materiales ?? [];
  List<Equipo> get _equipos =>
      _presupuestoActual?.equipos ?? widget.equipos ?? [];
  List<ManoObra> get _manoObra =>
      _presupuestoActual?.manoObra ?? widget.manoObra ?? [];
  Finanzas get _finanzas =>
      _presupuestoActual?.finanzas ?? widget.finanzas ?? Finanzas();
  String? get _titulo => _presupuestoActual?.titulo ?? widget.titulo;
  DateTime? get _fecha => _presupuestoActual?.fechaCreacion ?? widget.fecha;
  double? get _superficieM2 => _presupuestoActual?.superficieM2;
  EstadoPresupuesto? get _estado => _presupuestoActual?.estado;

  Future<void> _editarPresupuesto() async {
    final presupuesto = _presupuestoActual;
    if (presupuesto == null) return;

    final presupuestoActualizado = await Navigator.push<Presupuesto>(
      context,
      MaterialPageRoute(
        builder:
            (context) => WizardPresupuestoScreen(
              proyectoId: presupuesto.proyectoId,
              presupuesto: presupuesto,
            ),
      ),
    );

    if (presupuestoActualizado != null && mounted) {
      setState(() {
        _presupuestoActual = presupuestoActualizado;
      });
    }
  }

  Future<void> _exportarPdf() async {
    setState(() => _exportando = true);
    try {
      await PdfService().exportarPresupuesto(
        materiales: _materiales,
        equipos: _equipos,
        manoObra: _manoObra,
        finanzas: _finanzas,
        titulo: _titulo,
        fecha: _fecha,
        superficieM2: _superficieM2,
        estado: _estado,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar los getters del State para acceder a los datos
    final materialesList = _materiales;
    final equiposList = _equipos;
    final manoObraList = _manoObra;
    final finanzasData = _finanzas;
    final tituloText = _titulo;
    final fechaData = _fecha;

    // Calcular totales
    final totalMateriales = materialesList.fold<double>(
      0,
      (sum, m) => sum + m.total,
    );
    final totalManoObra = manoObraList.fold<double>(
      0,
      (sum, mo) => sum + mo.costo,
    );
    final totalEquipos = equiposList.fold<double>(0, (sum, e) => sum + e.total);

    // Calcular finanzas
    final calculadora = CalculadoraFinanzas();
    final resultados = calculadora.calcularTodo(
      totalMateriales: totalMateriales,
      totalManoObra: totalManoObra,
      totalEquipos: totalEquipos,
      finanzas: finanzasData,
    );

    final totalFinal = resultados['totalFinal']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Presupuesto'),
        elevation: 0,
        actions: [
          if (_presupuestoActual != null)
            IconButton(
              onPressed: _editarPresupuesto,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar presupuesto',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con título y fecha
            if (tituloText != null || fechaData != null)
              Card(
                color: AppColors.gray100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tituloText != null)
                        Text(
                          tituloText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (fechaData != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Fecha: ${fechaData.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Sección: Materiales
            SeccionMateriales(materiales: materialesList),
            const SizedBox(height: 12),

            // Sección: Mano de Obra
            SeccionManoObra(manoObra: manoObraList),
            const SizedBox(height: 12),

            // Sección: Equipos
            SeccionEquipos(equipos: equiposList),
            const SizedBox(height: 12),

            // Sección: Finanzas
            SeccionFinanzas(
              totalMateriales: totalMateriales,
              totalManoObra: totalManoObra,
              totalEquipos: totalEquipos,
              finanzas: finanzasData,
            ),
            const SizedBox(height: 16),

            // TOTAL FINAL - Destacado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.yellowSoft,
                border: Border.all(color: AppColors.yellowDark, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'TOTAL FINAL DEL PRESUPUESTO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    MonedaUtils.formatear(totalFinal),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    finanzasData.aplicarIVA
                        ? '(Incluye IVA ${finanzasData.porcentajeImprevistos.toStringAsFixed(1)}% imprevistos + ${finanzasData.porcentajeUtilidad.toStringAsFixed(1)}% utilidad)'
                        : '(Sin IVA - ${finanzasData.porcentajeImprevistos.toStringAsFixed(1)}% imprevistos + ${finanzasData.porcentajeUtilidad.toStringAsFixed(1)}% utilidad)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.gray700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Resumen de componentes
            Card(
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Desglose de Componentes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildComponente(
                      'Materiales',
                      totalMateriales,
                      totalFinal,
                      AppColors.info,
                    ),
                    _buildComponente(
                      'Mano de Obra',
                      totalManoObra,
                      totalFinal,
                      AppColors.gray900,
                    ),
                    _buildComponente(
                      'Equipos Rentados',
                      totalEquipos,
                      totalFinal,
                      AppColors.warning,
                    ),
                    _buildComponente(
                      'Imprevistos',
                      resultados['imprevistos']!,
                      totalFinal,
                      AppColors.yellowDark,
                    ),
                    _buildComponente(
                      'Utilidad',
                      resultados['utilidad']!,
                      totalFinal,
                      AppColors.success,
                    ),
                    if (finanzasData.aplicarIVA)
                      _buildComponente(
                        'IVA',
                        resultados['iva']!,
                        totalFinal,
                        AppColors.error,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Presupuesto guardado'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Guardar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportando ? null : _exportarPdf,
                    icon:
                        _exportando
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.picture_as_pdf),
                    label: Text(_exportando ? 'Generando...' : 'Exportar PDF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildComponente(
    String nombre,
    double monto,
    double total,
    Color color,
  ) {
    final porcentaje = total > 0 ? ((monto / total) * 100) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontSize: 12)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: porcentaje / 100,
                    backgroundColor: AppColors.gray300,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MonedaUtils.formatear(monto),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${porcentaje.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 11, color: AppColors.gray700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
