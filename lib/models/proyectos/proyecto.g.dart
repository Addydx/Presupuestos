// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proyecto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProyectoAdapter extends TypeAdapter<Proyecto> {
  @override
  final int typeId = 8;

  @override
  Proyecto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Proyecto(
      id: fields[0] as String,
      nombreProyecto: fields[1] as String,
      nombreCliente: fields[2] as String,
      descripcion: fields[3] as String?,
      imagenPath: fields[4] as String?,
      fechaCreacion: fields[5] as DateTime?,
      ubicacion: fields[6] as String?,
      fechaInicio: fields[7] as DateTime?,
      fechaFin: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Proyecto obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombreProyecto)
      ..writeByte(2)
      ..write(obj.nombreCliente)
      ..writeByte(3)
      ..write(obj.descripcion)
      ..writeByte(4)
      ..write(obj.imagenPath)
      ..writeByte(5)
      ..write(obj.fechaCreacion)
      ..writeByte(6)
      ..write(obj.ubicacion)
      ..writeByte(7)
      ..write(obj.fechaInicio)
      ..writeByte(8)
      ..write(obj.fechaFin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProyectoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
