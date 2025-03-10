import 'package:flutter/material.dart';
import 'report_generator.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportData = [
      ReportData(
        period: "Daily - March 9, 2025",
        totalSales: 28500,
        outstandingBalances: 3500,
        topSellingItems: [
          TopSellingItem(name: "Bibingka", quantity: 45, revenue: 11250),
          TopSellingItem(name: "Puto", quantity: 32, revenue: 4800),
        ],
      ),
      ReportData(
        period: "Weekly - March 3-9, 2025",
        totalSales: 192000,
        outstandingBalances: 8200,
        topSellingItems: [
          TopSellingItem(name: "Bibingka", quantity: 250, revenue: 62500),
          TopSellingItem(name: "Puto", quantity: 180, revenue: 27000),
          TopSellingItem(name: "Suman", quantity: 150, revenue: 30000),
        ],
      ),
      ReportData(
        period: "Monthly - March 2025",
        totalSales: 825000,
        outstandingBalances: 21500,
        topSellingItems: [
          TopSellingItem(name: "Bibingka", quantity: 750, revenue: 187500),
          TopSellingItem(name: "Puto", quantity: 540, revenue: 81000),
          TopSellingItem(name: "Suman", quantity: 450, revenue: 90000),
        ],
      ),
    ];

    return ReportGenerator(reports: reportData);
  }
}
