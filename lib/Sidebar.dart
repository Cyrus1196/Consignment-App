import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.deepOrange.shade100,
      child: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            selected: true,
          ),
          ListTile(leading: Icon(Icons.inventory), title: Text('Inventory')),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Consignment'),
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Transactions'),
          ),
          ListTile(leading: Icon(Icons.people), title: Text('Vendors')),
          ListTile(leading: Icon(Icons.bar_chart), title: Text('Reports')),
          ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
        ],
      ),
    );
  }
}
