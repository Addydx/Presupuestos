import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [TextFormField] que valida al perder el foco (no en cada tecla). Una vez
/// que el campo tuvo un error por primera vez, pasa a revalidar en vivo
/// (en cada tecla) para que el usuario vea el momento exacto en que lo
/// corrige.
///
/// El [fieldKey] y el [focusNode] los crea y posee el padre (el step o
/// pantalla que contiene el formulario), para poder armar la lista
/// ordenada de campos que usa [validarPasoYEnfocarError] al presionar
/// "Siguiente"/"Guardar".
class CampoValidado extends StatefulWidget {
  final GlobalKey<FormFieldState<String>> fieldKey;
  final FocusNode focusNode;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? siguienteFoco;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autofocus;
  final TextStyle? style;

  const CampoValidado({
    super.key,
    required this.fieldKey,
    required this.focusNode,
    required this.controller,
    required this.validator,
    required this.decoration,
    this.keyboardType,
    this.inputFormatters,
    this.siguienteFoco,
    this.textInputAction,
    this.onChanged,
    this.onSaved,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.autofocus = false,
    this.style,
  });

  @override
  State<CampoValidado> createState() => _CampoValidadoState();
}

class _CampoValidadoState extends State<CampoValidado> {
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_alCambiarFoco);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_alCambiarFoco);
    super.dispose();
  }

  void _alCambiarFoco() {
    if (!widget.focusNode.hasFocus) {
      widget.fieldKey.currentState?.validate();
    }
  }

  String? _validatorConSeguimiento(String? value) {
    final error = widget.validator(value);
    if (error != null && _autovalidateMode == AutovalidateMode.disabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _autovalidateMode == AutovalidateMode.disabled) {
          setState(
            () => _autovalidateMode = AutovalidateMode.onUserInteraction,
          );
        }
      });
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: widget.decoration,
      style: widget.style,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textInputAction:
          widget.textInputAction ??
          (widget.siguienteFoco != null
              ? TextInputAction.next
              : TextInputAction.done),
      validator: _validatorConSeguimiento,
      autovalidateMode: _autovalidateMode,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      onFieldSubmitted: (_) {
        final siguiente = widget.siguienteFoco;
        if (siguiente != null) {
          siguiente.requestFocus();
        } else {
          widget.focusNode.unfocus();
        }
      },
    );
  }
}

/// Un campo registrado para el escaneo de "primer error" de
/// [validarPasoYEnfocarError]: su [FormFieldState] (para saber si tiene
/// error y ubicarlo en pantalla) y su [FocusNode] (para enfocarlo).
typedef CampoRef = (GlobalKey<FormFieldState> fieldKey, FocusNode focusNode);

/// Valida un [Form] completo y, si hay errores, hace scroll hasta el
/// primer campo inválido (según el orden de [camposEnOrden]) y lo enfoca.
///
/// Devuelve `true` si el paso es válido y se puede avanzar.
bool validarPasoYEnfocarError({
  required GlobalKey<FormState> formKey,
  required List<CampoRef> camposEnOrden,
}) {
  final valido = formKey.currentState?.validate() ?? true;
  if (valido) return true;

  for (final (fieldKey, focusNode) in camposEnOrden) {
    if (fieldKey.currentState?.hasError ?? false) {
      final ctx = fieldKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
      }
      focusNode.requestFocus();
      break;
    }
  }
  return false;
}
