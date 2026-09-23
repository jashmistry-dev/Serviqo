import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/customer_providers.dart';

class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _altPhoneController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _pincodeController;
  String? _selectedCityId;
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _altPhoneController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _pincodeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _populateFields(dynamic profile) {
    if (profile == null || _isInitialized) return;
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _altPhoneController.text = profile.alternatePhone ?? '';
    _address1Controller.text = profile.addressLine1 ?? '';
    _address2Controller.text = profile.addressLine2 ?? '';
    _pincodeController.text = profile.pincode ?? '';
    _selectedCityId = profile.cityId;
    _isInitialized = true;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await ref.read(customerProfileNotifierProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          alternatePhone: _altPhoneController.text.trim().isEmpty ? null : _altPhoneController.text.trim(),
          cityId: _selectedCityId,
          addressLine1: _address1Controller.text.trim().isEmpty ? null : _address1Controller.text.trim(),
          addressLine2: _address2Controller.text.trim().isEmpty ? null : _address2Controller.text.trim(),
          pincode: _pincodeController.text.trim().isEmpty ? null : _pincodeController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF10B981),
          content: Text('Profile updated successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFEF4444),
          content: Text('Failed to update profile. Please verify your inputs.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(customerProfileNotifierProvider);
    final citiesAsync = ref.watch(citiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Customer Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                const SizedBox(height: 12),
                Text('Error loading profile: $err', style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(customerProfileNotifierProvider.notifier).loadProfile(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          if (!_isInitialized) {
            _populateFields(profile);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User info summary card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                          child: const Icon(Icons.person, color: Color(0xFF6366F1), size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile?.name ?? 'Customer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(profile?.email ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('VERIFIED CUSTOMER', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Personal Information', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Full Name', Icons.badge_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 14),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Phone is required';
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) return 'Valid 10-digit mobile number required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Alternate Phone
                  TextFormField(
                    controller: _altPhoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Alternate Phone (Optional)', Icons.phone_android_outlined),
                  ),

                  const SizedBox(height: 24),
                  const Text('Service Location & Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),

                  // Operating City Dropdown
                  citiesAsync.when(
                    data: (cities) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCityId,
                          hint: const Text('Select Operating City', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                          dropdownColor: const Color(0xFF1E293B),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          items: cities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city.id,
                              child: Text('${city.name}, ${city.state}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedCityId = val);
                          },
                        ),
                      ),
                    ),
                    loading: () => const LinearProgressIndicator(color: Color(0xFF6366F1)),
                    error: (err, st) => const Text('Failed to load cities', style: TextStyle(color: Color(0xFFEF4444))),
                  ),
                  const SizedBox(height: 14),

                  // Address Line 1
                  TextFormField(
                    controller: _address1Controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('House / Flat / Building', Icons.home_outlined),
                  ),
                  const SizedBox(height: 14),

                  // Address Line 2
                  TextFormField(
                    controller: _address2Controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Street / Area / Landmark', Icons.location_on_outlined),
                  ),
                  const SizedBox(height: 14),

                  // Pincode
                  TextFormField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('6-digit Pincode', Icons.pin_drop_outlined),
                  ),

                  const SizedBox(height: 30),

                  // Save Button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Profile Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
    );
  }
}
