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
import '../../features/customer/presentation/screens/customer_profile_screen.dart';
import '../../features/technician/presentation/screens/technician_dashboard_screen.dart';
import '../../features/technician/presentation/screens/technician_profile_screen.dart';
import '../../features/technician/presentation/screens/technician_verification_screen.dart';

/// Route path constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String registerCustomer = '/register/customer';
  static const String registerTechnician = '/register/technician';
  static const String customerHome = '/customer';
  static const String customerProfile = '/customer/profile';
  static const String technicianHome = '/technician';
  static const String technicianProfile = '/technician/profile';
  static const String technicianVerification = '/technician/verification';
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
        path: AppRoutes.customerProfile,
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.technicianHome,
        builder: (context, state) => const TechnicianDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.technicianProfile,
        builder: (context, state) => const TechnicianProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.technicianVerification,
        builder: (context, state) => const TechnicianVerificationScreen(),
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: (screenSize.height * 0.12).clamp(64.0, 96.0),
                          height: (screenSize.height * 0.12).clamp(64.0, 96.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_repair_service_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'SERVIQO',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verified Local Service Marketplace',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
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