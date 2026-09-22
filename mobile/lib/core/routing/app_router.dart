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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight =
                constraints.maxHeight.isFinite && constraints.maxHeight > 0
                    ? constraints.maxHeight
                    : 0.0;
            final minWidth =
                constraints.maxWidth.isFinite && constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : 0.0;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minHeight,
                  minWidth: minWidth,
                ),
                child: const IntrinsicHeight(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SERVIQO',
                            textAlign: TextAlign.center,
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
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0x99FFFFFF),
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 32),
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
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