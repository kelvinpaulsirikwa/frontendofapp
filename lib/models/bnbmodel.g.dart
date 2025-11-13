// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bnbmodel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SimpleMotelAdapter extends TypeAdapter<SimpleMotel> {
  @override
  final int typeId = 0;

  @override
  SimpleMotel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SimpleMotel(
      id: fields[0] as int,
      name: fields[1] as String,
      frontImage: fields[2] as String?,
      streetAddress: fields[3] as String,
      motelType: fields[4] as String,
      district: fields[5] as String,
      longitude: fields[6] as double?,
      latitude: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SimpleMotel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.frontImage)
      ..writeByte(3)
      ..write(obj.streetAddress)
      ..writeByte(4)
      ..write(obj.motelType)
      ..writeByte(5)
      ..write(obj.district)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.latitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleMotelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
