import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final String syncStatus;

  const Header({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.syncStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Kakanin Consignment App",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Icon(
                syncStatus == 'synced'
                    ? Icons.cloud_done
                    : syncStatus == 'syncing'
                    ? Icons.cloud_sync
                    : Icons.cloud_off,
                color:
                    syncStatus == 'synced'
                        ? Colors.green
                        : syncStatus == 'syncing'
                        ? Colors.blue
                        : Colors.grey,
              ),
              const SizedBox(width: 10),
              CircleAvatar(backgroundImage: NetworkImage(userAvatar)),
              const SizedBox(width: 8),
              Text(userName),
            ],
          ),
        ],
      ),
    );
  }
}
