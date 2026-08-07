import 'package:flutter/material.dart';
import 'package:presupuesto_app/models/presupuesto/finanzas.dart';
import 'package:presupuesto_app/screens/finanzas/finanzas_screen.dart';

class StepFinanzas extends StatefulWidget {
  /// Totales de otros módulos
  final double totalMateriales;
  final double totalManoObra;
  final double totalEquipos;

  /// Callback para capturar cambios en finanzas
  final Function(Finanzas) onFinanzasChanged;

  /// Finanzas inicial (opcional)
  final Finanzas? finanzasInicial;

  /// Permite al wizard validar este paso antes de avanzar.
  final GlobalKey<FormState>? formKey;

  /// Permite al wizard acceder al [FinanzasScreenState] (para hacer scroll
  /// hasta el primer campo inválido).
  final Key? finanzasScreenKey;

  const StepFinanzas({
    super.key,
    required this.totalMateriales,
    required this.totalManoObra,
    required this.totalEquipos,
    required this.onFinanzasChanged,
    this.finanzasInicial,
    this.formKey,
    this.finanzasScreenKey,
  });

  @override
  State<StepFinanzas> createState() => _StepFinanzasState();
}

class _StepFinanzasState extends State<StepFinanzas> {
  @override
  Widget build(BuildContext context) {
    return FinanzasScreen(
      key: widget.finanzasScreenKey,
      totalMateriales: widget.totalMateriales,
      totalManoObra: widget.totalManoObra,
      totalEquipos: widget.totalEquipos,
      onFinanzasChanged: widget.onFinanzasChanged,
      finanzasInicial: widget.finanzasInicial,
      formKey: widget.formKey,
    );
  }
}
