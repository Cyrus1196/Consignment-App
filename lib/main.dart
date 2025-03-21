import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'models/product_price.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ProductAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ProductPriceAdapter());
  }

  // Open Boxes
  await Hive.openBox<Product>('products');
  await Hive.openBox<ProductPrice>('product_prices');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kakanin Consignment',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
            devicePixelRatio: 1.0,
          ),
          child: child!,
        );
      },
      home: HomeScreen(),
    );
  }
}