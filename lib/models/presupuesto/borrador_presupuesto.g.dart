// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'borrador_presupuesto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BorradorPresupuestoAdapter extends TypeAdapter<BorradorPresupuesto> {
  @override
  final int typeId = 10;

  @override
  BorradorPresupuesto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BorradorPresupuesto(
      id: fields[0] as String,
      proyectoId: fields[1] as String,
      presupuestoIdEnEdicion: fields[2] as String?,
      pasoActual: fields[3] as int,
      titulo: fields[4] as String,
      superficieM2: fields[5] as double,
      fechaCreacion: fields[6] as DateTime,
      estado: fields[7] as EstadoPresupuesto,
      manoObra: fields[8] as ManoObra?,
      equipos: (fields[9] as List).cast<Equipo>(),
      materiales: (fields[10] as List).cast<MaterialPresupuesto>(),
      finanzas: fields[11] as Finanzas,
      ultimaModificacion: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BorradorPresupuesto obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.proyectoId)
      ..writeByte(2)
      ..write(obj.presupuestoIdEnEdicion)
      ..writeByte(3)
      ..write(obj.pasoActual)
      ..writeByte(4)
      ..write(obj.titulo)
      ..writeByte(5)
      ..write(obj.superficieM2)
      ..writeByte(6)
      ..write(obj.fechaCreacion)
      ..writeByte(7)
      ..write(obj.estado)
      ..writeByte(8)
      ..write(obj.manoObra)
      ..writeByte(9)
      ..write(obj.equipos)
      ..writeByte(10)
      ..write(obj.materiales)
      ..writeByte(11)
      ..write(obj.finanzas)
      ..writeByte(12)
      ..write(obj.ultimaModificacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorradorPresupuestoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
