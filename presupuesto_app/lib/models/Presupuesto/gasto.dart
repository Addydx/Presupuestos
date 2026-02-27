import 'package:hive/hive.dart';


@HiveType(typeId: 2)
class Gasto extends HiveObject {

  @HiveField(0)
  String nombre;

  @HiveField(1)
  double monto;

  @HiveField(2)
  String tipo; // directo / indirecto

  Gasto({
    required this.nombre,
    required this.monto,
    required this.tipo,
  });
}