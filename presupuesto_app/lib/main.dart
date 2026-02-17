import 'package:flutter/material.dart';
// Se mantiene un solo import de HomeScreen para evitar el error de import duplicado.
import 'package:presupuesto_app/screens/home/home_screen.dart';

void main() {
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
