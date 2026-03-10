// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mano_obra.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ManoObraAdapter extends TypeAdapter<ManoObra> {
  @override
  final int typeId = 2;

  @override
  ManoObra read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ManoObra(
      tipoPago: fields[0] as TipoPago,
      rol: fields[1] as String?,
      cantidadPersonas: fields[2] as int?,
      diasEstimados: fields[3] as int?,
      costoPorDia: fields[4] as double?,
      montoContrato: fields[5] as double?,
      observaciones: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ManoObra obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.tipoPago)
      ..writeByte(1)
      ..write(obj.rol)
      ..writeByte(2)
      ..write(obj.cantidadPersonas)
      ..writeByte(3)
      ..write(obj.diasEstimados)
      ..writeByte(4)
      ..write(obj.costoPorDia)
      ..writeByte(5)
      ..write(obj.montoContrato)
      ..writeByte(6)
      ..write(obj.observaciones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManoObraAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
