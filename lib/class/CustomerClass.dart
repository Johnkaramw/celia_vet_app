import 'package:hive/hive.dart';
part 'CustomerClass.g.dart';

@HiveType(typeId: 1)
class Customer extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  double paidAmount;

  Customer({
    required this.name,
    required this.phone,
    required this.totalAmount,
    required this.paidAmount,
  });

  double get remaining => totalAmount - paidAmount;
}
