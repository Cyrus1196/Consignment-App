import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double price;

  @HiveField(3)
  int soldQuantity;

  Product({
    required this.name,
    required this.quantity,
    required this.price,
    this.soldQuantity = 0,
  });

  double get totalBalance => price * soldQuantity;
  double get totalSales => price * soldQuantity; // Added this getter

  void updateSoldQuantity(int newSoldQuantity) {
    soldQuantity = newSoldQuantity;
    save(); // This will automatically save the changes to Hive
  }
}