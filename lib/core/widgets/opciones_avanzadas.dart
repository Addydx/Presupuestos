import 'package:flutter/material.dart';
import 'package:presupuesto_app/core/theme/app_colors.dart';

/// Contenedor colapsable para campos opcionales/avanzados. Cerrado por
/// defecto: el usuario nunca ve más de lo que necesita en ese momento.
class OpcionesAvanzadas extends StatelessWidget {
  final List<Widget> children;
  final String titulo;
  final bool initiallyExpanded;

  const OpcionesAvanzadas({
    super.key,
    required this.children,
    this.titulo = 'Mostrar opciones avanzadas',
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        // Mantiene los campos montados aun colapsados: un Form.validate()
        // disparado desde el botón "Siguiente"/"Guardar" debe poder ver
        // los campos avanzados aunque el usuario no haya abierto la
        // sección todavía.
        maintainState: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 4, bottom: 8),
        iconColor: AppColors.black,
        collapsedIconColor: AppColors.gray700,
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }
}
