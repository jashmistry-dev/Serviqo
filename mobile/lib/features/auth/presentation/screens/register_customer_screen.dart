import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class RegisterCustomerScreen extends ConsumerStatefulWidget {
  const RegisterCustomerScreen({super.key});

  @override
  ConsumerState<RegisterCustomerScreen> createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends ConsumerState<RegisterCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).registerCustomer(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          addressLine1: _addressController.text.trim(),
          pincode: _pincodeController.text.trim(),
        );

    if (success && mounted) {
      context.go(AppRoutes.customerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Customer Registration', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (authState is AuthError)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0x33EF4444),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF4444)),
                      ),
                      child: Text(
                        authState.message,
                        style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                      ),
                    ),
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
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Full Name *',
                              labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Email Address *',
                              labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                            validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Phone Number (10 digits) *',
                              labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                            validator: (v) => (v == null || v.trim().length < 10) ? '10-digit number required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password (min 8 chars) *',
                              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF94A3B8)),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Address Line / Flat / Area',
                              labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Pincode (e.g. 400001)',
                              labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                            ),
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
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Complete Registration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
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