import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class RegisterTechnicianScreen extends ConsumerStatefulWidget {
  const RegisterTechnicianScreen({super.key});

  @override
  ConsumerState<RegisterTechnicianScreen> createState() => _RegisterTechnicianScreenState();
}

class _RegisterTechnicianScreenState extends ConsumerState<RegisterTechnicianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController(text: '3');
  final _visitingChargeController = TextEditingController(text: '200');
  final _pincodeController = TextEditingController(text: '400050');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _visitingChargeController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).registerTechnician(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          experienceYears: int.tryParse(_experienceController.text) ?? 1,
          visitingCharge: double.tryParse(_visitingChargeController.text) ?? 150.0,
          bio: _bioController.text.trim(),
          pincode: _pincodeController.text.trim(),
        );

    if (success && mounted) {
      context.go(AppRoutes.technicianHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Technician Partner Registration', style: TextStyle(color: Colors.white, fontSize: 17)),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: Color(0xFF818CF8), size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Partners are verified based on submitted trade details and documents before receiving active jobs.',
                            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            decoration: const InputDecoration(labelText: 'Full Name *', labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Email Address *', labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                            validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Mobile Phone *', labelStyle: TextStyle(color: Color(0xFF94A3B8))),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _experienceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(labelText: 'Experience (Yrs) *', labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                                  validator: (v) => (v == null || int.tryParse(v) == null) ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _visitingChargeController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(labelText: 'Visit Charge (â‚¹) *', labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                                  validator: (v) => (v == null || double.tryParse(v) == null) ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bioController,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Short Trade Bio / Services Offered', labelStyle: TextStyle(color: Color(0xFF94A3B8))),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Operating Pincode (e.g. 400050)', labelStyle: TextStyle(color: Color(0xFF94A3B8))),
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
                                : const Text('Register as Partner', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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