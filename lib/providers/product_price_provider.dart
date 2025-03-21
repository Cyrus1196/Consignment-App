import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_price.dart';

class ProductPriceProvider extends ChangeNotifier {
  static final ProductPriceProvider _instance = ProductPriceProvider._internal();
  factory ProductPriceProvider() => _instance;
  ProductPriceProvider._internal();

  Map<String, double> productPrices = {};

  void updatePrices() {
    final box = Hive.box<ProductPrice>('product_prices');
    productPrices = Map.fromEntries(
      box.values.map((price) => MapEntry(price.name, price.price))
    );
    notifyListeners();
  }

  void updatePrice(String productName, double newPrice) {
    final box = Hive.box<ProductPrice>('product_prices');
    final priceIndex = box.values.toList().indexWhere((p) => p.name == productName);
    
    if (priceIndex != -1) {
      box.putAt(priceIndex, ProductPrice(name: productName, price: newPrice));
    } else {
      box.add(ProductPrice(name: productName, price: newPrice));
    }
    updatePrices();
  }
}