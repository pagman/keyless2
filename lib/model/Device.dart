import 'package:hive/hive.dart';
part'Device.g.dart';

@HiveType(typeId : 1)
class Device {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int meters;
  @HiveField(2)
  final bool auto;
  @HiveField(3)
  final bool approaching;

  Device(this.name, this.meters, this.auto, this.approaching);
}