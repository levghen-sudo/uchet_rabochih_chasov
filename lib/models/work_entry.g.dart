// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkEntryAdapter extends TypeAdapter<WorkEntry> {
  @override
  final int typeId = 0;

  @override
  WorkEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkEntry(
      id: fields[0] as String,
      fullName: fields[1] as String,
      date: fields[2] as DateTime,
      hours: fields[3] as double,
      tariffType: fields[4] as int,
      advance: fields[5] as double,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.hours)
      ..writeByte(4)
      ..write(obj.tariffType)
      ..writeByte(5)
      ..write(obj.advance)
      ..writeByte(6)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
