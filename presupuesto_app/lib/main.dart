import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:presupuesto_app/models/Proyectos/proyecto.dart';
// Se mantiene un solo import de HomeScreen para evitar el error de import duplicado.
import 'package:presupuesto_app/screens/home/home_screen.dart';
import 'package:presupuesto_app/models/Presupuesto/presupuesto.dart';
import 'package:presupuesto_app/models/Presupuesto/presupuesto.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProyectoAdapter());
  Hive.registerAdapter(PresupuestoAdapter());
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
      home: const HomeScreen(),
    );
  }
}
