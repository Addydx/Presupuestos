// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estado_proyecto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EstadoProyectoAdapter extends TypeAdapter<EstadoProyecto> {
  @override
  final int typeId = 2;

  @override
  EstadoProyecto read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EstadoProyecto.pendiente;
      case 1:
        return EstadoProyecto.activo;
      case 2:
        return EstadoProyecto.completado;
      case 3:
        return EstadoProyecto.cancelado;
      default:
        return EstadoProyecto.pendiente;
    }
  }

  @override
  void write(BinaryWriter writer, EstadoProyecto obj) {
    switch (obj) {
      case EstadoProyecto.pendiente:
        writer.writeByte(0);
        break;
      case EstadoProyecto.activo:
        writer.writeByte(1);
        break;
      case EstadoProyecto.completado:
        writer.writeByte(2);
        break;
      case EstadoProyecto.cancelado:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EstadoProyectoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
