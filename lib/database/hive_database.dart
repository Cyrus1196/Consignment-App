import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class HiveDatabase {
  static const String productsBoxName = 'products';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }

    await Hive.openBox<Product>(productsBoxName);
  }

  static Box<Product> getProductsBox() {
    return Hive.box<Product>(productsBoxName);
  }

  static Future<void> deleteStall(String stallName) async {
    final box = getProductsBox();
    final products = box.values.toList();
    
    // Find and delete all products from the specified stall
    for (var product in products) {
      if (product.name.contains('(Stall: $stallName)')) {
        final index = box.values.toList().indexOf(product);
        if (index != -1) {
          await box.deleteAt(index);
        }
      }
    }
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}