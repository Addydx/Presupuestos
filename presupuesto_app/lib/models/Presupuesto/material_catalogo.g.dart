// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_catalogo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialCatalogoAdapter extends TypeAdapter<MaterialCatalogo> {
  @override
  final int typeId = 7;

  @override
  MaterialCatalogo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialCatalogo(
      id: fields[0] as String?,
      nombre: fields[1] as String,
      categoria: fields[2] as String,
      unidad: fields[3] as String,
      precioReferencia: fields[4] as double,
      imagen: fields[5] as String?,
      tienda: fields[6] as String?,
      fechaCreacion: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialCatalogo obj) {
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
      ..write(obj.precioReferencia)
      ..writeByte(5)
      ..write(obj.imagen)
      ..writeByte(6)
      ..write(obj.tienda)
      ..writeByte(7)
      ..write(obj.fechaCreacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialCatalogoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
