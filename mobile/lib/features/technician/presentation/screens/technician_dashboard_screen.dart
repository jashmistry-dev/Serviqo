import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/technician_providers.dart';

class TechnicianDashboardScreen extends ConsumerWidget {
  const TechnicianDashboardScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is Authenticated ? authState.user : null;
    final profileAsync = ref.watch(technicianProfileNotifierProvider);
    final tech = profileAsync.value;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.handyman, color: Color(0xFF6366F1), size: 24),
            SizedBox(width: 8),
            Text(
              'Serviqo Partner',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Partner Profile',
            icon: const Icon(Icons.person_outline_rounded, color: Color(0xFF6366F1)),
            onPressed: () => context.push(AppRoutes.technicianProfile),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, color: Color(0xFF94A3B8)),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Technician Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF6366F1),
                          child: Text(
                            (user?.name.isNotEmpty == true ? user!.name[0] : 'T').toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Partner Technician',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(tech?.verificationStatus ?? 'pending').withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _statusColor(tech?.verificationStatus ?? 'pending').withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            (tech?.verificationStatus ?? 'PENDING').toUpperCase().replaceAll('_', ' '),
                            style: TextStyle(
                              color: _statusColor(tech?.verificationStatus ?? 'pending'),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF334155), height: 1),
                    const SizedBox(height: 12),

                    // Stats row: Visiting charge, rating, experience
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricItem(
                          'Visiting Fee',
                          '₹${tech?.visitingCharge.toStringAsFixed(0) ?? "150"}',
                          Icons.currency_rupee_rounded,
                        ),
                        _metricItem(
                          'Experience',
                          '${tech?.experienceYears ?? 3} Yrs',
                          Icons.work_history_rounded,
                        ),
                        _metricItem(
                          'Rating',
                          tech != null && tech.ratingCount > 0 ? '${tech.ratingAvg} ★' : 'New',
                          Icons.star_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Duty Availability Toggle Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (tech?.isAvailable == true)
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : const Color(0xFF334155),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (tech?.isAvailable == true) ? const Color(0xFF10B981) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (tech?.isAvailable == true) ? 'Online — Available for Requests' : 'Offline — Not Receiving Requests',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'First technician to accept locks the request',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: tech?.isAvailable ?? false,
                      activeTrackColor: const Color(0xFF10B981),
                      onChanged: (val) async {
                        final errorMsg = await ref
                            .read(technicianProfileNotifierProvider.notifier)
                            .toggleAvailability(val);

                        if (errorMsg != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFFEF4444),
                              content: Text(errorMsg),
                              action: SnackBarAction(
                                label: 'Verify Now',
                                textColor: Colors.white,
                                onPressed: () => context.push(AppRoutes.technicianVerification),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Verification Action Banner
              if (tech?.verificationStatus != 'verified')
                InkWell(
                  onTap: () => context.push(AppRoutes.technicianVerification),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          child: const Icon(Icons.shield_outlined, color: Color(0xFFF59E0B), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Complete Verification Dossier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Submit government ID or trade certification to accept jobs', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Incoming Service Requests Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Incoming Broadcast Requests', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF6366F1), size: 18),
                    onPressed: () => ref.read(technicianProfileNotifierProvider.notifier).loadProfile(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Empty Queue Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      child: const Icon(Icons.inbox_outlined, color: Color(0xFF6366F1), size: 30),
                    ),
                    const SizedBox(height: 12),
                    const Text('No Incoming Service Requests', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text(
                      'Broadcast requests will arrive in Phase 7-8 when customers create requests.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 14),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
      ],
    );
  }
}