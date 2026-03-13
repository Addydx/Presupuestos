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
      proyectoId: fields[1] as String,
      titulo: fields[2] as String,
      superficieM2: fields[3] as double,
      fechaCreacion: fields[4] as DateTime,
      estado: fields[5] as EstadoPresupuesto,
      version: fields[6] as int,
      manoObra: (fields[7] as List).cast<ManoObra>(),
      equipos: (fields[8] as List).cast<Equipo>(),
      materiales: (fields[9] as List).cast<MaterialPresupuesto>(),
      totalFinal: fields[10] as double,
      finanzas: fields[11] as Finanzas?,
    );
  }

  @override
  void write(BinaryWriter writer, Presupuesto obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.proyectoId)
      ..writeByte(2)
      ..write(obj.titulo)
      ..writeByte(3)
      ..write(obj.superficieM2)
      ..writeByte(4)
      ..write(obj.fechaCreacion)
      ..writeByte(5)
      ..write(obj.estado)
      ..writeByte(6)
      ..write(obj.version)
      ..writeByte(7)
      ..write(obj.manoObra)
      ..writeByte(8)
      ..write(obj.equipos)
      ..writeByte(9)
      ..write(obj.materiales)
      ..writeByte(10)
      ..write(obj.totalFinal)
      ..writeByte(11)
      ..write(obj.finanzas);
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
