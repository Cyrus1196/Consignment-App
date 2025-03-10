import 'package:flutter/material.dart';

class SalesData {
  final String label;
  final int amount;

  SalesData({required this.label, required this.amount});
}

class TopSellingItem {
  final String name;
  final int quantity;
  final double revenue;

  TopSellingItem({
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}

class SalesSummary extends StatelessWidget {
  final List<SalesData> dailySales;
  final List<SalesData> weeklySales;
  final List<TopSellingItem> topSellingItems;
  final int totalSales;

  const SalesSummary({
    super.key,
    required this.dailySales,
    required this.weeklySales,
    required this.topSellingItems,
    required this.totalSales,
  });

  Widget _buildSalesChart(List<SalesData> salesData, String title) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  salesData.map((data) {
                    return Column(
                      children: [
                        Container(
                          height:
                              (data.amount / 30000) *
                              100, // Scaling for visualization
                          width: 20,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 5),
                        Text(data.label, style: const TextStyle(fontSize: 12)),
                        Text(
                          '₱${data.amount}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingItems() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Selling Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children:
                  topSellingItems.map((item) {
                    return ListTile(
                      leading: const Icon(
                        Icons.local_dining,
                        color: Colors.deepOrange,
                      ),
                      title: Text(item.name),
                      subtitle: Text('${item.quantity} sold'),
                      trailing: Text('₱${item.revenue.toStringAsFixed(2)}'),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildSalesChart(dailySales, 'Daily Sales'),
          const SizedBox(height: 10),
          _buildSalesChart(weeklySales, 'Weekly Sales'),
          const SizedBox(height: 10),
          _buildTopSellingItems(),
          const SizedBox(height: 10),
          Card(
            elevation: 3,
            color: Colors.orangeAccent,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Total Sales: ₱${totalSales.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
