import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'header.dart';

class AppLayout extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final String syncStatus;
  final Widget child;

  const AppLayout({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.syncStatus,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Sidebar(),
        Expanded(
          child: Column(
            children: [
              Header(
                userName: userName,
                userAvatar: userAvatar,
                syncStatus: syncStatus,
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}
