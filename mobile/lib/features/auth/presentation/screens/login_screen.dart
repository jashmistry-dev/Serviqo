import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../domain/entities/user_entity.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo(String email, String password, UserRole role) {
    setState(() {
      _selectedRole = role;
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          expectedRole: _selectedRole.name,
        );

    if (success && mounted) {
      if (_selectedRole == UserRole.technician) {
        context.go(AppRoutes.technicianHome);
      } else {
        context.go(AppRoutes.customerHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding
                  const Icon(
                    Icons.home_repair_service_rounded,
                    size: 56,
                    color: Color(0xFF6366F1), // Indigo
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SERVIQO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Verified Local Service Marketplace',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  const SizedBox(height: 28),

                  // Role Selector
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = UserRole.customer),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == UserRole.customer
                                    ? const Color(0xFF6366F1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Customer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: _selectedRole == UserRole.customer
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = UserRole.technician),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == UserRole.technician
                                    ? const Color(0xFF6366F1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Technician',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: _selectedRole == UserRole.technician
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Banner
                  if (authState is AuthError)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x33EF4444),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF4444)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.message,
                              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Email or Phone',
                              labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                              prefixIcon: Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF334155)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFF94A3B8),
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF334155)),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF6366F1)),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    'Sign In as ${_selectedRole == UserRole.customer ? "Customer" : "Technician"}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Demo Credentials for Academic Review
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DEMO ACCOUNTS (Review & Testing):',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ActionChip(
                              label: const Text('Customer Demo', style: TextStyle(fontSize: 12, color: Colors.white)),
                              backgroundColor: const Color(0xFF334155),
                              onPressed: () => _fillDemo('customer@serviqo.com', 'Cust@123456', UserRole.customer),
                            ),
                            const SizedBox(width: 8),
                            ActionChip(
                              label: const Text('Technician Demo', style: TextStyle(fontSize: 12, color: Colors.white)),
                              backgroundColor: const Color(0xFF334155),
                              onPressed: () => _fillDemo('tech@serviqo.com', 'Tech@123456', UserRole.technician),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Registration Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                      TextButton(
                        onPressed: () {
                          if (_selectedRole == UserRole.technician) {
                            context.push(AppRoutes.registerTechnician);
                          } else {
                            context.push(AppRoutes.registerCustomer);
                          }
                        },
                        child: Text(
                          _selectedRole == UserRole.technician ? 'Register as Technician' : 'Register as Customer',
                          style: const TextStyle(color: Color(0xFF818CF8), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}