// screens/sales_report_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sales_report.dart';

class SalesReportScreen extends StatelessWidget {
  final List<Product> products;

  SalesReportScreen({required this.products});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs: Daily, Weekly, Monthly
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sales Report'),
          backgroundColor: Colors.green[800],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSalesReportView(
              SalesReport(dailySales: _calculateTotalSalesByPeriod(DateTime.now())),
            ),
            _buildSalesReportView(
              SalesReport(weeklySales: _calculateTotalSalesByWeek(DateTime.now())),
            ),
            _buildSalesReportView(
              SalesReport(monthlySales: _calculateTotalSalesByMonth(DateTime.now())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesReportView(SalesReport salesReport) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      if (salesReport.dailySales > 0)
                        _buildSalesItem('Daily Sales:', salesReport.dailySales),
                      if (salesReport.weeklySales > 0)
                        _buildSalesItem('Weekly Sales:', salesReport.weeklySales),
                      if (salesReport.monthlySales > 0)
                        _buildSalesItem('Monthly Sales:', salesReport.monthlySales),
                      if (salesReport.dailySales == 0 && 
                          salesReport.weeklySales == 0 && 
                          salesReport.monthlySales == 0)
                        Text(
                          'No sales data available.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            '₱${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalSalesByPeriod(DateTime date) {
    double totalSales = 0.0;
    // Implementation should be based on the product sales records
    for (var product in products) {
      if (product.soldQuantity > 0) {
        totalSales += product.totalSales; // Modify based on date filter for daily sales
      }
    }
    return totalSales;
  }

  double _calculateTotalSalesByWeek(DateTime date) {
    double totalSales = 0.0;
    // Add appropriate logic to calculate weekly total sales
    for (var product in products) {
      if (product.soldQuantity > 0) {
        totalSales += product.totalSales; // Modify logic as required
      }
    }
    return totalSales;
  }

  double _calculateTotalSalesByMonth(DateTime date) {
    double totalSales = 0.0;
    // Add appropriate logic to calculate monthly total sales
    for (var product in products) {
      if (product.soldQuantity > 0) {
        totalSales += product.totalSales; // Modify logic as required
      }
    }
    return totalSales;
  }
}