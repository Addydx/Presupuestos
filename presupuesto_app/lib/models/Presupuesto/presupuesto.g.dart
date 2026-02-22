import 'package:hive/hive.dart';
import 'presupuesto.dart';

class PresupuestoAdapter extends TypeAdapter<Presupuesto> {
  @override
  final int typeId = 1;

  @override
  Presupuesto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Presupuesto(
      id: fields[0] as String,
      nombre: fields[1] as String,
      descripcion: fields[2] as String,
      gastos:
          (fields[3] as List<dynamic>)
              .map(
                (dynamic e) => (e as Map<dynamic, dynamic>).map(
                  (key, value) => MapEntry(key as String, value),
                ),
              )
              .toList(),
      proyectoId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Presupuesto obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.gastos.map((gasto) => gasto.cast<String, dynamic>()).toList())
      ..writeByte(4)
      ..write(obj.proyectoId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresupuestoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
