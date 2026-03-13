import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';
import 'package:presupuesto_app/services/materiales_seed.dart';
import 'package:presupuesto_app/services/materiales_service.dart';
import 'package:presupuesto_app/services/equipos_service.dart';
import 'package:presupuesto_app/services/presupuestos_service.dart';

import 'package:presupuesto_app/screens/splash/splash_screen.dart';

import 'models/presupuesto/equipo.dart';
import 'models/presupuesto/finanzas.dart';
import 'models/presupuesto/mano_obra.dart';
import 'models/presupuesto/material.dart';
import 'models/presupuesto/material_catalogo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ProyectoAdapter());
  Hive.registerAdapter(PresupuestoAdapter());
  Hive.registerAdapter(ManoObraAdapter());
  Hive.registerAdapter(EquipoAdapter());
  Hive.registerAdapter(MaterialPresupuestoAdapter());
  Hive.registerAdapter(MaterialCatalogoAdapter());
  Hive.registerAdapter(FinanzasAdapter());

  await Hive.openBox<Proyecto>('proyectos');
  await Hive.openBox<Presupuesto>('presupuestos');

  // Inicializar MaterialesService (singleton)
  final materialesService = MaterialesService();
  await materialesService.initialize();

  // Cargar seed data si el catálogo está vacío
  await MaterialesSeed.inicializarCatalogo(materialesService);

  // Inicializar EquiposService (singleton)
  final equiposService = EquiposService();
  await equiposService.initialize();

  // Inicializar PresupuestosService (singleton)
  final presupuestosService = PresupuestosService();
  await presupuestosService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Presupuesto App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Fondo blanco predeterminado
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
