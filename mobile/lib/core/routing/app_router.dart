import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route path constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String customerHome = '/customer';
  static const String technicianHome = '/technician';
}

/// Application router provider.
/// Auth redirect guard will be wired in Step 3.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Customer Home'),
      ),
      GoRoute(
        path: AppRoutes.technicianHome,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Technician Home'),
      ),
    ],
  );
});

// ignore_for_file: unused_element_parameter
// These are private widgets only used via const — key is never passed externally.

class _SplashScreen extends StatelessWidget {
  // ignore: unused_element
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SERVIQO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Verified Local Service Marketplace',
              style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  // ignore: unused_element
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title — will be implemented in later steps.'),
      ),
    );
  }
}
