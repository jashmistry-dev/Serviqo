import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_customer_screen.dart';
import '../../features/auth/presentation/screens/register_technician_screen.dart';
import '../../features/customer/presentation/screens/customer_dashboard_screen.dart';
import '../../features/technician/presentation/screens/technician_dashboard_screen.dart';

/// Route path constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String registerCustomer = '/register/customer';
  static const String registerTechnician = '/register/technician';
  static const String customerHome = '/customer';
  static const String technicianHome = '/technician';
}

/// Application router provider.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerCustomer,
        builder: (context, state) => const RegisterCustomerScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerTechnician,
        builder: (context, state) => const RegisterTechnicianScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.technicianHome,
        builder: (context, state) => const TechnicianDashboardScreen(),
      ),
    ],
  );
});

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), _checkAndNavigate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkAndNavigate() {
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);

    if (authState is Authenticated) {
      if (authState.user.isTechnician) {
        context.go(AppRoutes.technicianHome);
      } else {
        context.go(AppRoutes.customerHome);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

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