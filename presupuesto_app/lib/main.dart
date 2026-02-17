import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:presupuesto_app/models/Proyectos/proyecto.dart';
// Se mantiene un solo import de HomeScreen para evitar el error de import duplicado.
import 'package:presupuesto_app/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProyectoAdapter());
  await Hive.openBox<Proyecto>('proyectos');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Presupuesto App',
      home: HomeScreen(),
    );
  }
}
