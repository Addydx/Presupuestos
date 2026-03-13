import 'package:hive/hive.dart';

part 'finanzas.g.dart';

@HiveType(typeId: 6)
class Finanzas {
  @HiveField(0)
  double porcentajeImprevistos;

  @HiveField(1)
  double porcentajeUtilidad;

  @HiveField(2)
  bool aplicarIVA;

  Finanzas({
    this.porcentajeImprevistos = 5.0,
    this.porcentajeUtilidad = 20.0,
    this.aplicarIVA = true,
  });
}
