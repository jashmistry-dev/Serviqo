import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/technician_providers.dart';

class TechnicianVerificationScreen extends ConsumerStatefulWidget {
  const TechnicianVerificationScreen({super.key});

  @override
  ConsumerState<TechnicianVerificationScreen> createState() => _TechnicianVerificationScreenState();
}

class _TechnicianVerificationScreenState extends ConsumerState<TechnicianVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDocType = 'government_id';
  final _docNumberController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _docNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // In mobile app, we simulate or attach document file
      // For academic demonstration, create a sample doc payload
      final repo = ref.read(technicianRepositoryProvider);
      await repo.uploadVerificationDoc(
        documentType: _selectedDocType,
        documentNumber: _docNumberController.text.trim().isNotEmpty ? _docNumberController.text.trim() : null,
        filePath: 'mock_doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
        fileName: 'verification_$_selectedDocType.pdf',
      );

      if (!mounted) return;
      ref.invalidate(technicianVerificationsProvider);
      ref.read(technicianProfileNotifierProvider.notifier).loadProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF10B981),
          content: Text('Document submitted for Super Admin verification.'),
        ),
      );
      _docNumberController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          content: Text('Upload failed: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
      case 'verified':
        return const Color(0xFF10B981);
      case 'under_review':
        return const Color(0xFFF59E0B);
      case 'rejected':
      case 'suspended':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(technicianProfileNotifierProvider);
    final verificationsAsync = ref.watch(technicianVerificationsProvider);
    final tech = profileAsync.value;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Partner Verification', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statusColor(tech?.verificationStatus ?? 'pending').withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Verification Dossier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(tech?.verificationStatus ?? 'pending').withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _statusColor(tech?.verificationStatus ?? 'pending')),
                        ),
                        child: Text(
                          (tech?.verificationStatus ?? 'PENDING').toUpperCase().replaceAll('_', ' '),
                          style: TextStyle(color: _statusColor(tech?.verificationStatus ?? 'pending'), fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tech?.verificationNotes ?? 'Upload government ID, trade license, or certifications to receive verified status from platform administrators.',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: Color(0xFF6366F1), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Verified based on submitted and reviewed information.',
                            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upload Document Section
            const Text('Submit Verification Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Document Type
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDocType,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Document Type',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        prefixIcon: Icon(Icons.description_outlined, color: Color(0xFF6366F1), size: 20),
                        filled: true,
                        fillColor: Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'government_id', child: Text('Government ID (Aadhaar / Voter ID)')),
                        DropdownMenuItem(value: 'police_clearance', child: Text('Police Clearance Certificate')),
                        DropdownMenuItem(value: 'certification', child: Text('Trade / Skill Certification')),
                        DropdownMenuItem(value: 'address_proof', child: Text('Utility Bill / Address Proof')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDocType = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Document Number
                    TextFormField(
                      controller: _docNumberController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Document / Registration Number (Optional)',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        prefixIcon: Icon(Icons.tag, color: Color(0xFF6366F1), size: 20),
                        filled: true,
                        fillColor: Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Submit Document Button
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isUploading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
                      label: Text(
                        _isUploading ? 'Submitting...' : 'Upload & Submit for Review',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Submitted Documents List
            const Text('Submitted Documents', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),

            verificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
              error: (e, _) => Text('Error loading documents: $e', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
              data: (docs) {
                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('No verification documents uploaded yet.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                            child: const Icon(Icons.file_present_rounded, color: Color(0xFF6366F1), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.documentType.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (doc.documentNumber != null)
                                  Text('No: ${doc.documentNumber}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(doc.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              doc.status.toUpperCase(),
                              style: TextStyle(color: _statusColor(doc.status), fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
