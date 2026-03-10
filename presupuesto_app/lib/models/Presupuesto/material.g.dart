// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialAdapter extends TypeAdapter<Material> {
  @override
  final int typeId = 4;

  @override
  Material read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Material(
      nombre: fields[0] as String,
      categoria: fields[1] as String,
      unidad: fields[2] as String,
      cantidad: fields[3] as double,
      precioUnitario: fields[4] as double,
      esPersonalizado: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Material obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.categoria)
      ..writeByte(2)
      ..write(obj.unidad)
      ..writeByte(3)
      ..write(obj.cantidad)
      ..writeByte(4)
      ..write(obj.precioUnitario)
      ..writeByte(5)
      ..write(obj.esPersonalizado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
