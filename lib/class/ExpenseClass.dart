import 'package:hive/hive.dart';
part 'ExpenseClass.g.dart';

@HiveType(typeId: 2)
class Expense extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String category;
  @HiveField(4)
  bool? isPaid;
  Expense({
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.isPaid = false,
  });
}
