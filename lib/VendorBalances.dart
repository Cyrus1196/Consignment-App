import 'package:flutter/material.dart';

class Vendor {
  final String id;
  final String name;
  final double totalBalance;
  final double lastPaymentAmount;
  final DateTime lastPaymentDate;
  final String status; // "paid", "partial", "pending"

  Vendor({
    required this.id,
    required this.name,
    required this.totalBalance,
    required this.lastPaymentAmount,
    required this.lastPaymentDate,
    required this.status,
  });
}

class VendorBalances extends StatefulWidget {
  final List<Vendor> vendors;

  const VendorBalances({super.key, required this.vendors});

  @override
  State<VendorBalances> createState() => _VendorBalancesState();
}

class _VendorBalancesState extends State<VendorBalances> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isSortedByName = true;

  // Filter logic
  List<Vendor> get _filteredVendors {
    return widget.vendors
        .where(
          (vendor) =>
              (_selectedFilter == 'All' ||
                  vendor.status == _selectedFilter.toLowerCase()) &&
              (vendor.name.toLowerCase().contains(_searchQuery.toLowerCase())),
        )
        .toList()
      ..sort(
        (a, b) =>
            _isSortedByName
                ? a.name.compareTo(b.name)
                : b.totalBalance.compareTo(a.totalBalance),
      );
  }

  // Status Badge for Paid, Partial, or Pending
  Widget _getStatusBadge(String status) {
    switch (status) {
      case "paid":
        return _statusBadge("Paid", Colors.green);
      case "partial":
        return _statusBadge("Partial", Colors.orange);
      case "pending":
        return _statusBadge("Pending", Colors.red);
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
              'Vendor Balances',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Search Bar
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search vendors...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),

            const SizedBox(height: 10),

            // Filter & Sort Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  ],
                  onChanged:
                      (value) => setState(() => _selectedFilter = value!),
                ),
                IconButton(
                  icon: Icon(
                    _isSortedByName ? Icons.sort_by_alpha : Icons.swap_vert,
                    color: Colors.orange,
                  ),
                  onPressed:
                      () => setState(() => _isSortedByName = !_isSortedByName),
                  tooltip: _isSortedByName ? 'Sort by Name' : 'Sort by Balance',
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Vendor List
            Column(
              children:
                  _filteredVendors.map((vendor) {
                    return ListTile(
                      leading: const Icon(
                        Icons.storefront,
                        color: Colors.deepOrange,
                      ),
                      title: Text(vendor.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance: ₱${vendor.totalBalance.toStringAsFixed(2)}',
                          ),
                          Text(
                            'Last Payment: ₱${vendor.lastPaymentAmount.toStringAsFixed(2)} on ${_formatDate(vendor.lastPaymentDate)}',
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getStatusBadge(vendor.status),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showActionMenu(context, vendor),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _showActionMenu(BuildContext context, Vendor vendor) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16.0),
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actions for ${vendor.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Record Payment'),
                  onTap: () => _recordPayment(context, vendor),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('View Details'),
                  onTap: () => _viewDetails(context, vendor),
                ),
                if (vendor.status != 'paid')
                  ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Send Reminder'),
                    onTap: () => _sendReminder(context, vendor),
                  ),
              ],
            ),
          ),
    );
  }

  void _recordPayment(BuildContext context, Vendor vendor) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recording payment for ${vendor.name}...')),
    );
  }

  void _viewDetails(BuildContext context, Vendor vendor) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${vendor.name}...')),
    );
  }

  void _sendReminder(BuildContext context, Vendor vendor) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending reminder to ${vendor.name}...')),
    );
  }
}
