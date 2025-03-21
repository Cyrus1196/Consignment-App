import 'package:hive/hive.dart';

part 'product_price.g.dart';

@HiveType(typeId: 2)
class ProductPrice extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double price;

  ProductPrice({required this.name, required this.price});
}