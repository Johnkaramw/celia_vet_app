import 'package:hive/hive.dart';
part 'class_Product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double buyPrice;

  @HiveField(2)
  double sellPrice;

  @HiveField(3)
  int quantityBought;

  @HiveField(4)
  int quantitySold;

  @HiveField(5)
  int soldQuantity;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? description;

  @HiveField(8)
  DateTime? expiryDate;

  @HiveField(9)
  String? authority;

  Product({
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantityBought,
    required this.quantitySold,
    required this.soldQuantity,
    required this.createdAt,
    this.description,
    this.expiryDate,
    this.authority,
  });

  int get quantityInStock => quantityBought - quantitySold;

  double get totalPurchase => quantityBought * buyPrice;

  double get totalSales => soldQuantity * sellPrice;

  double get profit => (soldQuantity * sellPrice) - (soldQuantity * buyPrice);

  Map<String, dynamic> toJson() => {
    'name': name,
    'buyPrice': buyPrice,
    'sellPrice': sellPrice,
    'quantityBought': quantityBought,
    'quantitySold': quantitySold,
    'soldQuantity': soldQuantity,
    'createdAt': createdAt.toIso8601String(),
    'description': description,
    'expiryDate': expiryDate?.toIso8601String(),
    'authority': authority,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    name: json['name'] ?? '',
    buyPrice: (json['buyPrice'] ?? 0).toDouble(),
    sellPrice: (json['sellPrice'] ?? 0).toDouble(),
    quantityBought: json['quantityBought'] ?? 0,
    quantitySold: json['quantitySold'] ?? 0,
    soldQuantity: json['soldQuantity'] ?? 0,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    description: json['description'],
    expiryDate: json['expiryDate'] != null
        ? DateTime.parse(json['expiryDate'])
        : null,
    authority: json['authority'],
  );
}
