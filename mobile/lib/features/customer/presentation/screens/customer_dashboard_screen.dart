import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is Authenticated ? authState.user : null;

    final categories = [
      {'name': 'Plumbing', 'icon': Icons.plumbing, 'desc': 'Leaks, taps, drainage', 'fee': 'From â‚¹150'},
      {'name': 'Electrical', 'icon': Icons.bolt, 'desc': 'Wiring, switches, fans', 'fee': 'From â‚¹150'},
      {'name': 'AC Service', 'icon': Icons.ac_unit, 'desc': 'Servicing, cooling, gas', 'fee': 'From â‚¹250'},
      {'name': 'Appliance', 'icon': Icons.kitchen, 'desc': 'Fridge, washing machine', 'fee': 'From â‚¹200'},
      {'name': 'Carpentry', 'icon': Icons.carpenter, 'desc': 'Doors, furniture, locks', 'fee': 'From â‚¹150'},
      {'name': 'Painting', 'icon': Icons.format_paint, 'desc': 'Seepage, wall painting', 'fee': 'From â‚¹200'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.home_repair_service_rounded, color: Color(0xFF6366F1), size: 24),
            SizedBox(width: 8),
            Text(
              'Serviqo Customer',
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
              // User Greeting Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user?.name ?? "Customer"}!',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'customer@serviqo.com',
                      style: const TextStyle(color: Color(0xFFE0E7FF), fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 4),
                          Text('Active Customer Account', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Categories Header
              const Text(
                'Browse Verified Service Categories',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Transparent visiting charges shown upfront before requesting technicians.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Category Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(cat['icon'] as IconData, color: const Color(0xFF818CF8), size: 28),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cat['fee'] as String,
                                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat['name'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              cat['desc'] as String,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Business Workflow Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How Serviqo Works', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      '1. Create a service problem request (not a direct booking)\n'
                      '2. Broadcast to multiple verified technicians in your area\n'
                      '3. First technician to accept locks the request atomically\n'
                      '4. Technician visits, inspects and prepares detailed quote\n'
                      '5. Review quotation before repair commences',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.5),
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