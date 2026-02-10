import 'package:flutter/material.dart';

class ProyectosScreens  extends StatefulWidget{
  const ProyectosScreens({super.key});

  @override
  State<ProyectosScreens> createState() => _ProyectosScreenState();
}

class _ProyectosScreenState extends State<ProyectosScreens>{
  final _fromKey = GlobalKey<FormState>();//esto es solo para vaidadr el formulario

  final nombreController = TextEditingController();
  final clienteController = TextEditingController();
  final direccionController = TextEditingController();
  final notasController = TextEditingController();

  String tipoObra = 'casa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear proyecto")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _fromKey,
          child: ListView(
            children: [],
          ),
        ),
      ),
    );
  }
}
