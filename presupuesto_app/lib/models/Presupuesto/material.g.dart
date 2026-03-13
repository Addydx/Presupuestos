// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialPresupuestoAdapter extends TypeAdapter<MaterialPresupuesto> {
  @override
  final int typeId = 0;

  @override
  MaterialPresupuesto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialPresupuesto(
      id: fields[0] as String?,
      nombre: fields[1] as String,
      categoria: fields[2] as String,
      unidad: fields[3] as String,
      cantidad: fields[4] as double,
      precioUnitario: fields[5] as double,
      esPersonalizado: fields[6] as bool,
      materialCatalogoId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialPresupuesto obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.categoria)
      ..writeByte(3)
      ..write(obj.unidad)
      ..writeByte(4)
      ..write(obj.cantidad)
      ..writeByte(5)
      ..write(obj.precioUnitario)
      ..writeByte(6)
      ..write(obj.esPersonalizado)
      ..writeByte(7)
      ..write(obj.materialCatalogoId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialPresupuestoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
