// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finanzas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinanzasAdapter extends TypeAdapter<Finanzas> {
  @override
  final int typeId = 6;

  @override
  Finanzas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Finanzas(
      porcentajeimprevistos: fields[0] as double,
      porcentajeUtilidad: fields[1] as double,
      aplicarIVA: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Finanzas obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.porcentajeimprevistos)
      ..writeByte(1)
      ..write(obj.porcentajeUtilidad)
      ..writeByte(2)
      ..write(obj.aplicarIVA);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanzasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
