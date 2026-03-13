import 'package:hive/hive.dart';

part 'finanzas.g.dart';

@HiveType(typeId: 6)
class Finanzas {
  @HiveField(0)
  double porcentajeimprevistos;

  @HiveField(1)
  double porcentajeUtilidad;

  @HiveField(2)
  bool aplicarIVA;

  Finanzas({
    required this.porcentajeimprevistos,
    required this.porcentajeUtilidad,
    required this.aplicarIVA,
  });
}
