import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:presupuesto_app/models/presupuesto/equipo.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/models/presupuesto/mano_obra.dart';
import 'package:presupuesto_app/models/presupuesto/material.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/services/calculadora_finanzas.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  PdfService._internal();
  factory PdfService() => _instance;

  // ─── Colores de la app ───────────────────────────────────────────────────
  // Espejo en PdfColor de lib/core/theme/app_colors.dart (el paquete pdf no
  // puede consumir dart:ui Color directamente).
  static const _amarillo = PdfColor.fromInt(0xFFFFC300);
  static const _amarilloOscuro = PdfColor.fromInt(0xFFD9A400);
  static const _amarilloSuave = PdfColor.fromInt(0xFFFFF3CC);
  static const _negro = PdfColor.fromInt(0xFF101010);
  static const _gris700 = PdfColor.fromInt(0xFF3D3D3D);
  static const _gris300 = PdfColor.fromInt(0xFFD6D6D6);
  static const _gris100 = PdfColor.fromInt(0xFFF2F2F2);
  static const _blanco = PdfColor.fromInt(0xFFFFFFFF);
  static const _exito = PdfColor.fromInt(0xFF2E7D32);
  static const _advertencia = PdfColor.fromInt(0xFFED6C02);
  static const _error = PdfColor.fromInt(0xFFC62828);
  static const _info = PdfColor.fromInt(0xFF0277BD);

  /// Genera el PDF y abre el diálogo de impresión / compartir del sistema.
  Future<void> exportarPresupuesto({
    required List<MaterialPresupuesto> materiales,
    required List<Equipo> equipos,
    required List<ManoObra> manoObra,
    required Finanzas finanzas,
    String? titulo,
    DateTime? fecha,
    double? superficieM2,
    EstadoPresupuesto? estado,
  }) async {
    final pdf = await _generarPdf(
      materiales: materiales,
      equipos: equipos,
      manoObra: manoObra,
      finanzas: finanzas,
      titulo: titulo,
      fecha: fecha,
      superficieM2: superficieM2,
      estado: estado,
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${(titulo ?? 'presupuesto').replaceAll(' ', '_')}.pdf',
    );
  }

  // ─── Construcción del documento ─────────────────────────────────────────
  Future<pw.Document> _generarPdf({
    required List<MaterialPresupuesto> materiales,
    required List<Equipo> equipos,
    required List<ManoObra> manoObra,
    required Finanzas finanzas,
    String? titulo,
    DateTime? fecha,
    double? superficieM2,
    EstadoPresupuesto? estado,
  }) async {
    // Fuentes base (incluidas en el paquete pdf, sin necesidad de assets)
    final fontRegular = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    // Calcular totales
    final totalMateriales = materiales.fold<double>(0, (s, m) => s + m.total);
    final totalManoObra = manoObra.fold<double>(0, (s, mo) => s + mo.costo);
    final totalEquipos = equipos.fold<double>(0, (s, e) => s + e.total);

    final calculadora = CalculadoraFinanzas();
    final resultados = calculadora.calcularTodo(
      totalMateriales: totalMateriales,
      totalManoObra: totalManoObra,
      totalEquipos: totalEquipos,
      finanzas: finanzas,
    );

    final totalFinal = resultados['totalFinal']!;

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(titulo, fecha, superficieM2, estado),
        footer: (ctx) => _buildFooter(ctx),
        build:
            (ctx) => [
              pw.SizedBox(height: 12),
              // ── Materiales
              if (materiales.isNotEmpty) ...[
                _seccionTitulo('Materiales'),
                pw.SizedBox(height: 6),
                _tablaMateriales(materiales),
                pw.SizedBox(height: 4),
                _filaTotalSeccion('Total Materiales', totalMateriales),
                pw.SizedBox(height: 16),
              ],
              // ── Mano de Obra
              if (manoObra.isNotEmpty) ...[
                _seccionTitulo('Mano de Obra'),
                pw.SizedBox(height: 6),
                _tablaManoObra(manoObra),
                pw.SizedBox(height: 4),
                _filaTotalSeccion('Total Mano de Obra', totalManoObra),
                pw.SizedBox(height: 16),
              ],
              // ── Equipos
              if (equipos.isNotEmpty) ...[
                _seccionTitulo('Equipos Rentados'),
                pw.SizedBox(height: 6),
                _tablaEquipos(equipos),
                pw.SizedBox(height: 4),
                _filaTotalSeccion('Total Equipos', totalEquipos),
                pw.SizedBox(height: 16),
              ],
              // ── Resumen financiero
              _seccionTitulo('Resumen Financiero'),
              pw.SizedBox(height: 6),
              _tablaFinanzas(resultados, finanzas),
              pw.SizedBox(height: 20),
              // ── Total final
              _cajaTotal(totalFinal, finanzas),
            ],
      ),
    );

    return doc;
  }

  // ─── Encabezado de página ────────────────────────────────────────────────
  pw.Widget _buildHeader(
    String? titulo,
    DateTime? fecha,
    double? superficieM2,
    EstadoPresupuesto? estado,
  ) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        color: _negro,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PRESUPUESTO',
                style: pw.TextStyle(
                  color: _blanco,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.normal,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                titulo ?? 'Sin título',
                style: pw.TextStyle(
                  color: _blanco,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (fecha != null)
                pw.Text(
                  'Fecha: ${_formatearFecha(fecha)}',
                  style: const pw.TextStyle(color: _blanco, fontSize: 9),
                ),
              if (superficieM2 != null && superficieM2 > 0) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'Superficie: ${superficieM2.toStringAsFixed(2)} m²',
                  style: const pw.TextStyle(color: _blanco, fontSize: 9),
                ),
              ],
              if (estado != null) ...[
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _colorEstado(estado),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                  ),
                  child: pw.Text(
                    _etiquetaEstado(estado),
                    style: pw.TextStyle(
                      color: _colorTextoEstado(estado),
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── Pie de página ───────────────────────────────────────────────────────
  pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generado el ${_formatearFecha(DateTime.now())}',
            style: const pw.TextStyle(color: _gris700, fontSize: 8),
          ),
          pw.Text(
            'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: const pw.TextStyle(color: _gris700, fontSize: 8),
          ),
        ],
      ),
    );
  }

  // ─── Título de sección ───────────────────────────────────────────────────
  pw.Widget _seccionTitulo(String texto) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const pw.BoxDecoration(
        color: _amarillo,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        texto.toUpperCase(),
        style: pw.TextStyle(
          color: _negro,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─── Tabla de materiales ─────────────────────────────────────────────────
  pw.Widget _tablaMateriales(List<MaterialPresupuesto> materiales) {
    const encabezados = [
      'Nombre',
      'Categoría',
      'Unidad',
      'Cantidad',
      'P. Unit.',
      'Total',
    ];
    final filas =
        materiales
            .map(
              (m) => [
                m.nombre,
                m.categoria,
                m.unidad,
                m.cantidad.toStringAsFixed(2),
                '\$${m.precioUnitario.toStringAsFixed(2)}',
                '\$${m.total.toStringAsFixed(2)}',
              ],
            )
            .toList();
    return _tablaGenerica(encabezados, filas, [3, 2, 1.2, 1.2, 1.5, 1.5]);
  }

  // ─── Tabla de mano de obra ───────────────────────────────────────────────
  pw.Widget _tablaManoObra(List<ManoObra> manoObra) {
    const encabezados = ['Rol', 'Tipo Pago', 'Detalle', 'Costo'];
    final filas =
        manoObra.map((mo) {
          final tipoPago =
              mo.tipoPago == TipoPago.porDia ? 'Por Día' : 'Contrato';
          final detalle =
              mo.tipoPago == TipoPago.porDia
                  ? '${mo.cantidadPersonas ?? 0} pers. × ${mo.diasEstimados ?? 0} días'
                  : 'Monto fijo';
          return [
            mo.rol ?? '-',
            tipoPago,
            detalle,
            '\$${mo.costo.toStringAsFixed(2)}',
          ];
        }).toList();
    return _tablaGenerica(encabezados, filas, [2.5, 1.5, 2.5, 1.5]);
  }

  // ─── Tabla de equipos ────────────────────────────────────────────────────
  pw.Widget _tablaEquipos(List<Equipo> equipos) {
    const encabezados = ['Equipo', 'Costo / Día', 'Días', 'Total'];
    final filas =
        equipos
            .map(
              (e) => [
                e.nombre,
                '\$${e.costoPorDia.toStringAsFixed(2)}',
                e.dias.toString(),
                '\$${e.total.toStringAsFixed(2)}',
              ],
            )
            .toList();
    return _tablaGenerica(encabezados, filas, [3, 2, 1, 2]);
  }

  // ─── Tabla de resumen financiero ─────────────────────────────────────────
  pw.Widget _tablaFinanzas(Map<String, double> r, Finanzas finanzas) {
    final filas = [
      [
        'Costo Directo (Materiales + M.O. + Equipos)',
        '\$${r['costoDirecto']!.toStringAsFixed(2)}',
      ],
      [
        'Imprevistos (${finanzas.porcentajeImprevistos.toStringAsFixed(1)}%)',
        '\$${r['imprevistos']!.toStringAsFixed(2)}',
      ],
      ['Subtotal', '\$${r['subtotal']!.toStringAsFixed(2)}'],
      [
        'Utilidad (${finanzas.porcentajeUtilidad.toStringAsFixed(1)}%)',
        '\$${r['utilidad']!.toStringAsFixed(2)}',
      ],
      ['Precio antes de IVA', '\$${r['precioFinal']!.toStringAsFixed(2)}'],
      if (finanzas.aplicarIVA)
        ['IVA (16%)', '\$${r['iva']!.toStringAsFixed(2)}'],
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: _gris300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        // Encabezado
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _negro),
          children: [
            _celdaEncabezado('Concepto'),
            _celdaEncabezado('Monto', alinear: pw.Alignment.centerRight),
          ],
        ),
        // Filas
        ...filas.map(
          (fila) => pw.TableRow(
            children: [
              _celdaDato(fila[0]),
              _celdaDato(fila[1], alinear: pw.Alignment.centerRight),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Fila de total por sección ───────────────────────────────────────────
  pw.Widget _filaTotalSeccion(String etiqueta, double monto) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: const pw.BoxDecoration(
          color: _gris100,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          '$etiqueta: \$${monto.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _negro,
          ),
        ),
      ),
    );
  }

  // ─── Caja del total final ─────────────────────────────────────────────────
  pw.Widget _cajaTotal(double totalFinal, Finanzas finanzas) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _amarilloSuave,
        border: pw.Border.all(color: _amarilloOscuro, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'TOTAL FINAL DEL PRESUPUESTO',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _negro,
              letterSpacing: 1,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '\$${totalFinal.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
              color: _negro,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            finanzas.aplicarIVA
                ? 'Incluye IVA · ${finanzas.porcentajeImprevistos.toStringAsFixed(1)}% imprevistos · ${finanzas.porcentajeUtilidad.toStringAsFixed(1)}% utilidad'
                : 'Sin IVA · ${finanzas.porcentajeImprevistos.toStringAsFixed(1)}% imprevistos · ${finanzas.porcentajeUtilidad.toStringAsFixed(1)}% utilidad',
            style: const pw.TextStyle(fontSize: 8, color: _gris700),
          ),
        ],
      ),
    );
  }

  // ─── Tabla genérica ──────────────────────────────────────────────────────
  pw.Widget _tablaGenerica(
    List<String> encabezados,
    List<List<String>> filas,
    List<double> anchos,
  ) {
    final columnWidths = <int, pw.TableColumnWidth>{};
    for (var i = 0; i < anchos.length; i++) {
      columnWidths[i] = pw.FlexColumnWidth(anchos[i]);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _gris300, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Encabezado
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _negro),
          children: encabezados.map((e) => _celdaEncabezado(e)).toList(),
        ),
        // Filas alternadas
        ...filas.asMap().entries.map((entry) {
          final esImpar = entry.key.isOdd;
          return pw.TableRow(
            decoration:
                esImpar ? null : const pw.BoxDecoration(color: _gris100),
            children: entry.value.map((c) => _celdaDato(c)).toList(),
          );
        }),
      ],
    );
  }

  // ─── Celdas ──────────────────────────────────────────────────────────────
  pw.Widget _celdaEncabezado(
    String texto, {
    pw.Alignment alinear = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      alignment: alinear,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: _blanco,
        ),
      ),
    );
  }

  pw.Widget _celdaDato(
    String texto, {
    pw.Alignment alinear = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      alignment: alinear,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(texto, style: const pw.TextStyle(fontSize: 8)),
    );
  }

  // ─── Utilidades ──────────────────────────────────────────────────────────
  String _formatearFecha(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  PdfColor _colorEstado(EstadoPresupuesto estado) {
    switch (estado) {
      case EstadoPresupuesto.aprobado:
        return _exito;
      case EstadoPresupuesto.rechazado:
        return _error;
      case EstadoPresupuesto.enviado:
        return _info;
      case EstadoPresupuesto.cancelado:
        return _gris700;
      case EstadoPresupuesto.borrador:
        return _advertencia;
    }
  }

  /// Color de texto legible (WCAG AA) sobre la superficie de [_colorEstado].
  PdfColor _colorTextoEstado(EstadoPresupuesto estado) {
    return estado == EstadoPresupuesto.borrador ? _negro : _blanco;
  }

  String _etiquetaEstado(EstadoPresupuesto estado) {
    switch (estado) {
      case EstadoPresupuesto.borrador:
        return 'BORRADOR';
      case EstadoPresupuesto.enviado:
        return 'ENVIADO';
      case EstadoPresupuesto.aprobado:
        return 'APROBADO';
      case EstadoPresupuesto.rechazado:
        return 'RECHAZADO';
      case EstadoPresupuesto.cancelado:
        return 'CANCELADO';
    }
  }
}
