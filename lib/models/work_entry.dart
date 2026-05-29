import 'package:hive_flutter/hive_flutter.dart';

part 'work_entry.g.dart';

@HiveType(typeId: 0)
class WorkEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  double hours;

  @HiveField(4)
  int tariffType;

  @HiveField(5)
  double advance;

  @HiveField(6)
  String? note;

  WorkEntry({
    required this.id,
    required this.fullName,
    required this.date,
    required this.hours,
    required this.tariffType,
    required this.advance,
    this.note,
  });
}