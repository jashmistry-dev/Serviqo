import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';

class TechnicianDashboardScreen extends ConsumerStatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  ConsumerState<TechnicianDashboardScreen> createState() => _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends ConsumerState<TechnicianDashboardScreen> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is Authenticated ? authState.user : null;

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
              // Technician Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Technician Partner',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? 'tech@serviqo.com',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                              SizedBox(width: 4),
                              Text('VERIFIED', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Verified based on submitted and reviewed information.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Duty Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isAvailable ? const Color(0xFF10B981) : const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAvailable ? 'Currently Available' : 'Currently Offline',
                          style: TextStyle(
                            color: _isAvailable ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'Broadcasted service requests are sent when available',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      activeTrackColor: const Color(0xFF10B981),
                      onChanged: (v) => setState(() => _isAvailable = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Metrics Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Visiting Charge', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          SizedBox(height: 4),
                          Text('â‚¹250.00', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Payable upon visit', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer Rating', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              SizedBox(width: 4),
                              Text('4.85', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text('42 verified reviews', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Incoming Broadcast Requests
              const Text(
                'Incoming Service Requests',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inbox_outlined, color: Color(0xFF64748B), size: 40),
                    SizedBox(height: 8),
                    Text(
                      'No Pending Broadcast Requests',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'When customers submit requests in your category and city, they will appear here. The first technician to accept locks the request.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
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
}