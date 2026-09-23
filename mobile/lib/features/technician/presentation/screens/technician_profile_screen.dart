import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../customer/presentation/providers/customer_providers.dart';
import '../providers/technician_providers.dart';

class TechnicianProfileScreen extends ConsumerStatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  ConsumerState<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends ConsumerState<TechnicianProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _expController;
  late TextEditingController _visitingFeeController;
  late TextEditingController _addressController;
  late TextEditingController _pincodeController;
  String? _selectedCityId;
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _expController = TextEditingController();
    _visitingFeeController = TextEditingController();
    _addressController = TextEditingController();
    _pincodeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _expController.dispose();
    _visitingFeeController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _populate(dynamic tech) {
    if (tech == null || _isInitialized) return;
    _nameController.text = tech.name;
    _phoneController.text = tech.phone;
    _bioController.text = tech.bio ?? '';
    _expController.text = tech.experienceYears.toString();
    _visitingFeeController.text = tech.visitingCharge.toStringAsFixed(0);
    _selectedCityId = tech.cityId;
    _isInitialized = true;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await ref.read(technicianProfileNotifierProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
          experienceYears: int.tryParse(_expController.text.trim()),
          visitingCharge: double.tryParse(_visitingFeeController.text.trim()),
          cityId: _selectedCityId,
          address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
          pincode: _pincodeController.text.trim().isNotEmpty ? _pincodeController.text.trim() : null,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF10B981),
          content: Text('Technician profile updated successfully'),
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
    final profileAsync = ref.watch(technicianProfileNotifierProvider);
    final citiesAsync = ref.watch(citiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Partner Profile & Rates', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white70))),
        data: (tech) {
          if (!_isInitialized) _populate(tech);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Full Name', Icons.person_outline),
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
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) return 'Valid 10-digit number required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Bio / Background
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Professional Bio & Specialization', Icons.badge_outlined),
                  ),
                  const SizedBox(height: 14),

                  // Experience Years & Visiting Fee Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Experience (Yrs)', Icons.work_history_outlined),
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 0) return 'Valid years required';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _visitingFeeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Visiting Fee (\u20B9)', Icons.currency_rupee_rounded),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n < 0) return 'Valid fee required';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

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
                          hint: const Text('Select Operating City', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                          dropdownColor: const Color(0xFF1E293B),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: cities.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name}, ${c.state}'))).toList(),
                          onChanged: (val) => setState(() => _selectedCityId = val),
                        ),
                      ),
                    ),
                    loading: () => const LinearProgressIndicator(color: Color(0xFF6366F1)),
                    error: (err, st) => const Text('Error loading cities', style: TextStyle(color: Color(0xFFEF4444))),
                  ),
                  const SizedBox(height: 14),

                  // Workshop / Business Address
                  TextFormField(
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Workshop / Operating Address', Icons.home_repair_service_outlined),
                  ),
                  const SizedBox(height: 14),

                  // Pincode
                  TextFormField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Operating Pincode', Icons.pin_drop_outlined),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Profile & Rates', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
