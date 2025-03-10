import 'package:flutter/material.dart';
import 'InventorySummary.dart';
import 'SalesSummary.dart';
import 'VendorBalances.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Inventory Data
    final inventoryItems = [
      InventoryItem(
        id: "1",
        name: "Bibingka",
        quantity: 45,
        price: 25.0,
        consignmentStatus: "available",
      ),
      InventoryItem(
        id: "2",
        name: "Puto",
        quantity: 32,
        price: 15.0,
        consignmentStatus: "consigned",
      ),
      InventoryItem(
        id: "3",
        name: "Suman",
        quantity: 18,
        price: 20.0,
        consignmentStatus: "low",
      ),
      InventoryItem(
        id: "4",
        name: "Kutsinta",
        quantity: 27,
        price: 18.0,
        consignmentStatus: "available",
      ),
      InventoryItem(
        id: "5",
        name: "Sapin-Sapin",
        quantity: 12,
        price: 30.0,
        consignmentStatus: "consigned",
      ),
    ];

    // Sales Data
    final dailySales = [
      SalesData(label: 'Mon', amount: 12500),
      SalesData(label: 'Tue', amount: 18200),
      SalesData(label: 'Wed', amount: 15800),
      SalesData(label: 'Thu', amount: 21000),
      SalesData(label: 'Fri', amount: 24500),
      SalesData(label: 'Sat', amount: 28000),
      SalesData(label: 'Sun', amount: 19500),
    ];

    final weeklySales = [
      SalesData(label: 'Week 1', amount: 85000),
      SalesData(label: 'Week 2', amount: 92000),
      SalesData(label: 'Week 3', amount: 88500),
      SalesData(label: 'Week 4', amount: 105000),
    ];

    final topSellingItems = [
      TopSellingItem(name: "Bibingka", quantity: 250, revenue: 25000),
      TopSellingItem(name: "Puto", quantity: 180, revenue: 18000),
      TopSellingItem(name: "Suman", quantity: 150, revenue: 15000),
      TopSellingItem(name: "Kutsinta", quantity: 120, revenue: 12000),
      TopSellingItem(name: "Sapin-Sapin", quantity: 100, revenue: 10000),
    ];

    // Vendor Data
    final vendors = [
      Vendor(
        id: "1",
        name: "Mang Juan Store",
        totalBalance: 2500,
        lastPaymentAmount: 1500,
        lastPaymentDate: DateTime(2023, 5, 15),
        status: "partial",
      ),
      Vendor(
        id: "2",
        name: "Aling Maria Bakery",
        totalBalance: 0,
        lastPaymentAmount: 3000,
        lastPaymentDate: DateTime(2023, 5, 20),
        status: "paid",
      ),
      Vendor(
        id: "3",
        name: "Barangay Sari-Sari Store",
        totalBalance: 4500,
        lastPaymentAmount: 500,
        lastPaymentDate: DateTime(2023, 5, 10),
        status: "partial",
      ),
      Vendor(
        id: "4",
        name: "City Market Stall",
        totalBalance: 1800,
        lastPaymentAmount: 0,
        lastPaymentDate: DateTime(2023, 5, 1),
        status: "pending",
      ),
      Vendor(
        id: "5",
        name: "School Canteen",
        totalBalance: 3200,
        lastPaymentAmount: 800,
        lastPaymentDate: DateTime(2023, 5, 12),
        status: "partial",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InventorySummary(items: inventoryItems),
            const SizedBox(height: 16),
            SalesSummary(
              dailySales: dailySales,
              weeklySales: weeklySales,
              topSellingItems: topSellingItems,
              totalSales: 139500,
            ),
            const SizedBox(height: 16),
            VendorBalances(vendors: vendors),
          ],
        ),
      ),
    );
  }
}
