import 'package:flutter/material.dart';

class InventoryItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String consignmentStatus;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.consignmentStatus,
  });
}

class InventorySummary extends StatelessWidget {
  final List<InventoryItem> items;

  const InventorySummary({super.key, required this.items});

  // Status Badge for Available, Consigned, Low Stock
  Widget _getStatusBadge(String status) {
    switch (status) {
      case "available":
        return _statusBadge("Available", Colors.green);
      case "consigned":
        return _statusBadge("Consigned", Colors.blue);
      case "low":
        return _statusBadge("Low Stock", Colors.red);
      default:
        return _statusBadge("Unknown", Colors.grey);
    }
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Inventory Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(3), // Name
                1: FlexColumnWidth(2), // Quantity
                2: FlexColumnWidth(2), // Price
                3: FlexColumnWidth(3), // Status
              },
              children: [
                _buildTableHeader(),
                ...items.map(_buildTableRow).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Colors.orangeAccent),
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Kakanin Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Quantity',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Price (₱)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  TableRow _buildTableRow(InventoryItem item) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(item.name)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${item.quantity}'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('₱${item.price.toStringAsFixed(2)}'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: _getStatusBadge(item.consignmentStatus)),
        ),
      ],
    );
  }
}
