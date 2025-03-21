// View_Stall_Activity.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/product_price.dart';  // Moved import to top
import '../database/hive_database.dart';
import 'package:collection/collection.dart'; // For easier grouping

import '../providers/product_price_provider.dart';

class StallActivityScreen extends StatefulWidget {
  @override
  _StallActivityScreenState createState() => _StallActivityScreenState();
}

class _StallActivityScreenState extends State<StallActivityScreen> {
  List<Product> products = [];
  Map<String, double> productPrices = {};
  final Map<Product, TextEditingController> _soldControllers = {};
  final Map<Product, int> _currentSoldQuantities = {};

  final priceProvider = ProductPriceProvider();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    priceProvider.updatePrices();
  }

  void _loadProducts() {
    final box = HiveDatabase.getProductsBox();
    setState(() {
      products = box.values.toList();
      // Initialize controllers for each product
      for (var product in products) {
        _soldControllers[product] = TextEditingController();
        _currentSoldQuantities[product] = product.soldQuantity;
      }
    });
  }

  void _loadProductPrices() {
    final box = Hive.box<ProductPrice>('product_prices');
    setState(() {
      productPrices = Map.fromEntries(
        box.values.map((price) => MapEntry(price.name, price.price))
      );
    });
  }

  void _updateSales(Product product) {
    int soldQty = int.tryParse(_soldControllers[product]!.text) ?? 0;

    if (soldQty >= 0 && soldQty <= product.quantity) {
      final box = HiveDatabase.getProductsBox();
      int productIndex = box.values.toList().indexOf(product);
      if (productIndex != -1) {
        final productName = product.name.split('(')[0].trim();
        final currentPrice = priceProvider.productPrices[productName] ?? product.price;
        product.updateSoldQuantity(soldQty);
        product.price = currentPrice; // Update with current price
        box.putAt(productIndex, product);
        
        setState(() {
          _loadProducts();
          _loadProductPrices();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated ${product.name.split('(')[0].trim()} sold quantity to $soldQty')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid sold quantity!')),
      );
    }
  }

  void _changeSoldQuantity(Product product) {
    // Set the text field to the current sold quantity
    _soldControllers[product]!.text = _currentSoldQuantities[product].toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Changed to current sold quantity for ${product.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group products by their stall owner name
    var groupedProducts = groupBy<Product, String>(
      products, // Use the state variable instead of widget.products
      (Product product) => product.name.split('(Stall: ')[1].split(')')[0], // Extract stall name
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stall Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg2.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: groupedProducts.keys.length,
            itemBuilder: (context, index) {
              String stallName = groupedProducts.keys.elementAt(index);
              List<Product> productsInStall = groupedProducts[stallName]!;
              double totalStallSales = productsInStall.fold(
                0.0,
                (sum, product) => sum + product.totalBalance,
              );

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[800],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.store, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                stallName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total Sales: ₱${totalStallSales.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...productsInStall.map((product) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product title and price row
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16, // Smaller avatar
                                  backgroundColor: Colors.brown[100],
                                  child: Icon(Icons.fastfood, size: 18, color: Colors.brown[800]),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name.split('(')[0].trim(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Price: ₱${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Info cards in a more compact layout
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.28,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue[300]!),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('Quantity',
                                            style: TextStyle(color: Colors.blue[700])),
                                        SizedBox(height: 8),
                                        Text('${product.quantity}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[900])),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 24),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.28,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green[300]!),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('Sold',
                                            style: TextStyle(color: Colors.green[700])),
                                        SizedBox(height: 8),
                                        Text('${product.soldQuantity}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[900])),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 24),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.28,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange[300]!),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('Sales',
                                            style: TextStyle(color: Colors.orange[700])),
                                        SizedBox(height: 8),
                                        Text('₱${product.totalBalance.toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange[900])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            // Update quantity controls
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: _soldControllers[product],
                                    decoration: InputDecoration(
                                      labelText: 'Sold',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateSales(product),
                                    icon: Icon(Icons.update, size: 16),
                                    label: Text('Update', style: TextStyle(fontSize: 14)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[600],
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle final updates
          Navigator.pop(context);
        },
        icon: Icon(Icons.check),
        label: Text('Done'),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      width: 110, // Fixed width for consistent sizing
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    final box = HiveDatabase.getProductsBox();
    for (var product in products) { // Use the state variable
      int productIndex = box.values.toList().indexOf(product);
      if (productIndex != -1) {
        box.putAt(productIndex, product);
      }
    }
    
    for (var controller in _soldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}