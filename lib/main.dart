import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'DashboardContent.dart';
import 'LoginForm.dart';
import 'report_screen.dart';

void main() {
  runApp(const ConsignmentApp());
}

class ConsignmentApp extends StatelessWidget {
  const ConsignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Router Configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(isAuthenticated: true),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginForm()),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportScreen(),
    ),
  ],
);

class HomeScreen extends StatelessWidget {
  final bool isAuthenticated;
  const HomeScreen({super.key, this.isAuthenticated = true});

  @override
  Widget build(BuildContext context) {
    return isAuthenticated ? const DashboardContent() : const LoginForm();
  }
}
