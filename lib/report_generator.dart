import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class ReportData {
  final String period;
  final double totalSales;
  final double outstandingBalances;
  final List<TopSellingItem> topSellingItems;

  ReportData({
    required this.period,
    required this.totalSales,
    required this.outstandingBalances,
    required this.topSellingItems,
  });
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

class ReportGenerator extends StatelessWidget {
  final List<ReportData> reports;

  const ReportGenerator({super.key, required this.reports});

  Future<void> _generatePDF(BuildContext context, ReportData report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Sales Report - ${report.period}',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Total Sales: ₱${report.totalSales.toStringAsFixed(2)}',
                ),
                pw.Text(
                  'Outstanding Balances: ₱${report.outstandingBalances.toStringAsFixed(2)}',
                ),
                pw.SizedBox(height: 10),

                pw.Text(
                  'Top Selling Items:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Table.fromTextArray(
                  headers: ['Item Name', 'Quantity', 'Revenue'],
                  data:
                      report.topSellingItems.map((item) {
                        return [
                          item.name,
                          item.quantity.toString(),
                          '₱${item.revenue.toStringAsFixed(2)}',
                        ];
                      }).toList(),
                ),
              ],
            ),
      ),
    );

    // Save the PDF file
    final output = await getExternalStorageDirectory();
    final filePath = '${output!.path}/Sales_Report_${report.period}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved at: $filePath'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Generation'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 3,
            child: ListTile(
              title: Text(
                '${report.period} Report',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Sales: ₱${report.totalSales.toStringAsFixed(2)}'),
                  Text(
                    'Outstanding Balances: ₱${report.outstandingBalances.toStringAsFixed(2)}',
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.orange),
                onPressed: () => _generatePDF(context, report),
              ),
            ),
          );
        },
      ),
    );
  }
}
