import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:hive_flutter/hive_flutter.dart';  // Add this import
import '../models/product_price.dart';
import '../providers/product_price_provider.dart';  // Add this import

// Replace the constant map with a variable that can be updated

class AddProductScreen extends StatefulWidget {
  final Function(Product) onAddProduct;

  AddProductScreen({required this.onAddProduct});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

// Add this class definition before _ProductInputDialogState
class ProductInputDialog extends StatefulWidget {
  final Function(Product) onAddProduct;

  ProductInputDialog({required this.onAddProduct});

  @override
  _ProductInputDialogState createState() => _ProductInputDialogState();
}

// Add the updateProductPrice method here

class _AddProductScreenState extends State<AddProductScreen> {
  final priceProvider = ProductPriceProvider();
  Map<String, List<Product>> stallProducts = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
    priceProvider.updatePrices();
  }

  // Replace _loadProductPrices and getProductPrices with this
  Map<String, double> get productPrices => priceProvider.productPrices;

  void updateProductPrice(String productName, double newPrice) {
    priceProvider.updatePrice(productName, newPrice);
    
    // Update existing products with new price
    final productsBox = Hive.box<Product>('products');
    final products = productsBox.values.toList();
    
    for (var i = 0; i < products.length; i++) {
      var product = products[i];
      if (product.name.split('(')[0].trim() == productName) {
        var updatedProduct = Product(
          name: product.name,
          quantity: product.quantity,
          price: newPrice,
        );
        productsBox.putAt(i, updatedProduct);
      }
    }
    
    _loadProducts();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Price updated for $productName')),
      );
    }
  }
  


  void _showEditProductDialog(BuildContext context, Product product) {
    TextEditingController quantityController = TextEditingController(text: product.quantity.toString());
    TextEditingController priceController = TextEditingController(text: product.price.toString());
    String? selectedProduct = product.name.split('(')[0].trim();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Product'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedProduct,
                    items: productPrices.keys.map((String product) {
                      return DropdownMenuItem<String>(
                        value: product,
                        child: Text(product),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      selectedProduct = newValue;
                    },
                    decoration: InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      int newQuantity = int.tryParse(value) ?? 0;
                      if (newQuantity >= 0) {
                        // Update in Hive
                        final box = Hive.box<Product>('products');
                        int productIndex = box.values.toList().indexOf(product);
                        if (productIndex != -1) {
                          product.quantity = newQuantity;
                          box.putAt(productIndex, product);
                          
                          // Update in state
                          setState(() {
                            String stallName = product.name.split('(Stall: ')[1].split(')')[0];
                            int listIndex = stallProducts[stallName]!.indexOf(product);
                            stallProducts[stallName]![listIndex].quantity = newQuantity;
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: '₱',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    double newPrice = double.tryParse(priceController.text) ?? 0;
                    int newQuantity = int.tryParse(quantityController.text) ?? 0;
                    if (newQuantity > 0 && newPrice > 0) {
                      // Update product price in the map
                      updateProductPrice(selectedProduct!, newPrice);
                      
                      final box = Hive.box<Product>('products');
                      String stallInfo = product.name.substring(product.name.indexOf('(Stall:'));
                      Product updatedProduct = Product(
                        name: '$selectedProduct $stallInfo',
                        quantity: newQuantity,
                        price: newPrice,
                      );
                      
                      // Update in Hive
                      int productIndex = box.values.toList().indexOf(product);
                      if (productIndex != -1) {
                        box.putAt(productIndex, updatedProduct);
                      }

                      setState(() {
                        String stallName = product.name.split('(Stall: ')[1].split(')')[0];
                        int listIndex = stallProducts[stallName]!.indexOf(product);
                        stallProducts[stallName]![listIndex] = updatedProduct;
                      });
                      
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter valid quantity and price')),
                      );
                    }
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _loadProducts() {
    final box = Hive.box<Product>('products');
    final products = box.values.toList();
    
    setState(() {
      stallProducts.clear();
      for (var product in products) {
        String stallName = product.name.split('(Stall: ')[1].split(')')[0];
        if (!stallProducts.containsKey(stallName)) {
          stallProducts[stallName] = [];
        }
        stallProducts[stallName]!.add(product);
      }
    });
  }

  void _onAddProduct(Product product) {
    final box = Hive.box<Product>('products');
    box.add(product);  // Save to Hive

    setState(() {
      String stallName = product.name.split('(Stall: ')[1].split(')')[0];
      if (!stallProducts.containsKey(stallName)) {
        stallProducts[stallName] = [];
      }
      bool productExists = stallProducts[stallName]!.any(
        (p) => p.name.split('(')[0].trim() == product.name.split('(')[0].trim()
      );
      if (!productExists) {
        stallProducts[stallName]!.add(product);
      }
    });
    widget.onAddProduct(product);
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete All Products'),
          content: Text('Are you sure you want to delete all products?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final box = Hive.box<Product>('products');
                box.clear();
                setState(() {
                  stallProducts.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All products deleted')),
                );
              },
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteStallDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Stall'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: stallProducts.length,
              itemBuilder: (context, index) {
                String stallName = stallProducts.keys.elementAt(index);
                return ListTile(
                  leading: Icon(Icons.store),
                  title: Text(stallName),
                  onTap: () {
                    _deleteStall(stallName);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _deleteStall(String stallName) {
    final box = Hive.box<Product>('products');
    final productsToDelete = stallProducts[stallName] ?? [];
    
    for (var product in productsToDelete) {
      int index = box.values.toList().indexOf(product);
      if (index != -1) {
        box.deleteAt(index);
      }
    }

    setState(() {
      stallProducts.remove(stallName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stall "$stallName" deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Product to Stall',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.delete),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'all',
                child: ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Delete All Stalls'),
                ),
              ),
              PopupMenuItem(
                value: 'stall',
                child: ListTile(
                  leading: Icon(Icons.store, color: Colors.red),
                  title: Text('Delete Stall'),
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'all') {
                _showDeleteAllDialog();
              } else if (value == 'stall') {
                _showDeleteStallDialog();
              }
            },
          ),
        ],
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
        child: stallProducts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No products added yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to add products to your stall',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: stallProducts.length,
                itemBuilder: (context, index) {
                  String stallName = stallProducts.keys.elementAt(index);
                  List<Product> products = stallProducts[stallName]!;
                  
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
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
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.store, color: Colors.white),
                                title: Text(
                                  'Stall: $stallName',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(Icons.phone, color: Colors.white70, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Mobile: ${products.first.name.split('(Mobile: ')[1].split(')')[0]}',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          itemBuilder: (context, productIndex) {
                            final product = products[productIndex];
                            final date = product.name.split('(Date: ')[1].split(')')[0];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.brown[100],
                                child: Icon(Icons.fastfood, color: Colors.brown[800]),
                              ),
                              title: Text(
                                product.name.split('(')[0].trim(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('Quantity: ${product.quantity}'),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '₱${product.price}',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () => _showEditProductDialog(context, product),
                            );
                          },
                        ),
                        // Add total calculation section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              ...products.map((product) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${product.name.split('(')[0].trim()}: ${product.quantity} x ₱${product.price}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      '₱${(product.quantity * product.price).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                              Divider(color: Colors.green[800]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Value:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₱${products.fold(0.0, (sum, product) => sum + (product.quantity * product.price)).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        icon: Icon(Icons.add),
        label: Text('Add Product'),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProductInputDialog(onAddProduct: _onAddProduct);
      },
    );
  }
}

class _ProductInputDialogState extends State<ProductInputDialog> {
  final priceProvider = ProductPriceProvider();
  Map<String, double> get productPrices => priceProvider.productPrices;
  
  @override
  void initState() {
    super.initState();
    priceProvider.updatePrices();
  }

  final _stallNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _productQuantityController = TextEditingController();
  String? _selectedProduct;  // Add this field
  List<Product> _addedProducts = [];  // Add this field

  void _addProduct() {
    String stallName = _stallNameController.text.trim();
    String mobileNumber = _mobileNumberController.text.trim();
    int quantity = int.tryParse(_productQuantityController.text.trim()) ?? 0;

    // Perform validation
    if (stallName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stall Name cannot be empty!')));
      return;
    }

    if (mobileNumber.isEmpty || mobileNumber.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid 11-digit mobile number!')));
      return;
    }

    if (!mobileNumber.startsWith('09')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mobile number must start with 09!')));
      return;
    }

    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a product!')));
      return;
    }

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quantity must be greater than zero!')));
      return;
    }

    // Check if product already exists in _addedProducts
    bool productExists = _addedProducts.any(
      (p) => p.name.split('(')[0].trim() == _selectedProduct
    );
    
    if (productExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This product is already added!'))
      );
      return;
    }

    // Create and add the product if all validations pass
    double price = productPrices[_selectedProduct]!;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    final product = Product(
      name: '$_selectedProduct (Stall: $stallName) (Mobile: $mobileNumber) (Date: $dateStr)',
      quantity: quantity,
      price: price,
    );

    setState(() {
      _addedProducts.add(product);
    });

    // Clear only product selection and quantity
    _productQuantityController.clear();
    setState(() {
      _selectedProduct = null;
    });
  }

  void _saveAndClose() {
    // Send all products to parent
    for (var product in _addedProducts) {
      widget.onAddProduct(product);
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _stallNameController.dispose();
    _mobileNumberController.dispose();
    _productQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Input Product Details',
                style: TextStyle(fontSize: 24, color: Colors.green[800], fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Adjust the spacing
              SizedBox(height: 12),
              
              // Make text fields more compact
              TextField(
                controller: _stallNameController,
                decoration: InputDecoration(
                  labelText: 'Stall Name',
                  labelStyle: TextStyle(color: Colors.green[800]),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              SizedBox(height: 8),
              
              // Adjust other form fields similarly
              TextField(
                controller: _mobileNumberController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  labelStyle: TextStyle(color: Colors.green[800]),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone, color: Colors.green[800]),
                  hintText: '09XX XXX XXXX',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedProduct,
                items: productPrices.keys.map((String product) {
                  return DropdownMenuItem<String>(
                    value: product,
                    child: Text(product),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProduct = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Product',
                  labelStyle: TextStyle(color: Colors.green[800]),
                  border: OutlineInputBorder(),
                ),
              ),
              if (_selectedProduct != null) ...[
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _productQuantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(color: Colors.green[800]),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Price: ₱${productPrices[_selectedProduct]}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_addedProducts.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(
                  'Added Products:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 200, // Fixed height for scrollable area
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(), // Enable scrolling
                    itemCount: _addedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _addedProducts[index];
                      return ListTile(
                        dense: true, // Make items more compact
                        title: Text(product.name.split('(')[0].trim()),
                        subtitle: Text('Quantity: ${product.quantity} - Price: ₱${product.price}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _addedProducts.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addProduct,
                    child: Text('Add More'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveAndClose,
                    child: Text('Submit'),  // Changed from 'Save All' to 'Submit'
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}