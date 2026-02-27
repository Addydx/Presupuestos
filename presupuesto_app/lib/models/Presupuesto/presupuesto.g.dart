// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuesto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      costosDirectos: (fields[3] as List).cast<Gasto>(),
      costosIndirectos: (fields[4] as List).cast<Gasto>(),
      margenGanancia: fields[5] as double,
      proyectoId: fields[6] as String,
      fechaCreacion: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Presupuesto obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.costosDirectos)
      ..writeByte(4)
      ..write(obj.costosIndirectos)
      ..writeByte(5)
      ..write(obj.margenGanancia)
      ..writeByte(6)
      ..write(obj.proyectoId)
      ..writeByte(7)
      ..write(obj.fechaCreacion);
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
