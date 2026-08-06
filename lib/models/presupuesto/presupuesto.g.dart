// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuesto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresupuestoAdapter extends TypeAdapter<Presupuesto> {
  @override
  final int typeId = 4;

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

class EstadoPresupuestoAdapter extends TypeAdapter<EstadoPresupuesto> {
  @override
  final int typeId = 5;

  @override
  EstadoPresupuesto read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EstadoPresupuesto.borrador;
      case 1:
        return EstadoPresupuesto.enviado;
      case 2:
        return EstadoPresupuesto.aprobado;
      case 3:
        return EstadoPresupuesto.rechazado;
      case 4:
        return EstadoPresupuesto.cancelado;
      default:
        return EstadoPresupuesto.borrador;
    }
  }

  @override
  void write(BinaryWriter writer, EstadoPresupuesto obj) {
    switch (obj) {
      case EstadoPresupuesto.borrador:
        writer.writeByte(0);
        break;
      case EstadoPresupuesto.enviado:
        writer.writeByte(1);
        break;
      case EstadoPresupuesto.aprobado:
        writer.writeByte(2);
        break;
      case EstadoPresupuesto.rechazado:
        writer.writeByte(3);
        break;
      case EstadoPresupuesto.cancelado:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EstadoPresupuestoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
