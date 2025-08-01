import 'package:hive/hive.dart';
import '../class/CustomerClass.dart';

class CustomerStorage {
  static Future<void> saveCustomers(List<Customer> customers) async {
    final box = await Hive.openBox<Customer>('customers');
    await box.clear();
    await box.addAll(customers);
  }

  static Future<List<Customer>> loadCustomers() async {
    final box = await Hive.openBox<Customer>('customers');
    return box.values.toList();
  }
}
