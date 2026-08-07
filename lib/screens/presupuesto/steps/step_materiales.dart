import 'package:flutter/material.dart';
import 'package:presupuesto_app/screens/materiales/materiales_presupuesto_screen.dart';
import 'package:presupuesto_app/services/materiales_service.dart';

class StepMateriales extends StatefulWidget {
  final MaterialesService materialesService;
  final VoidCallback? onCambio;

  const StepMateriales({
    super.key,
    required this.materialesService,
    this.onCambio,
  });

  @override
  State<StepMateriales> createState() => _StepMaterialesState();
}

class _StepMaterialesState extends State<StepMateriales> {
  @override
  Widget build(BuildContext context) {
    return MaterialesPresupuestoScreen(
      materialesService: widget.materialesService,
      onCambio: widget.onCambio,
    );
  }
}
