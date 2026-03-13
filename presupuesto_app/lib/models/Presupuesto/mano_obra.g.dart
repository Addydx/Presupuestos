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
      id: fields[0] as String?,
      tipoPago: fields[1] as TipoPago,
      rol: fields[2] as String?,
      cantidadPersonas: fields[3] as int?,
      diasEstimados: fields[4] as int?,
      costoPorDia: fields[5] as double?,
      montoContrato: fields[6] as double?,
      observaciones: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ManoObra obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tipoPago)
      ..writeByte(2)
      ..write(obj.rol)
      ..writeByte(3)
      ..write(obj.cantidadPersonas)
      ..writeByte(4)
      ..write(obj.diasEstimados)
      ..writeByte(5)
      ..write(obj.costoPorDia)
      ..writeByte(6)
      ..write(obj.montoContrato)
      ..writeByte(7)
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
