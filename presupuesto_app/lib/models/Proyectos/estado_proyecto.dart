import 'package:hive/hive.dart';

part 'estado_proyecto.g.dart';

@HiveType(typeId: 2)
enum EstadoProyecto {
  @HiveField(0)
  pendiente,
  @HiveField(1)
  activo,
  @HiveField(2)
  completado,
  @HiveField(3)
  cancelado,
}
