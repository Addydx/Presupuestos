import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:presupuesto_app/models/proyectos/proyecto.dart';
import 'package:presupuesto_app/models/presupuesto/presupuesto.dart';

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
