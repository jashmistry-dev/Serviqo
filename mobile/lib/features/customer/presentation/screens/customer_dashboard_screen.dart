import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/customer_providers.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  const CustomerDashboardScreen({super.key});

  IconData _getCategoryIcon(String slug) {
    if (slug.contains('ac') || slug.contains('cool') || slug.contains('air')) {
      return Icons.ac_unit_rounded;
    } else if (slug.contains('plumb')) {
      return Icons.plumbing_rounded;
    } else if (slug.contains('electr')) {
      return Icons.bolt_rounded;
    } else if (slug.contains('appliance')) {
      return Icons.kitchen_rounded;
    } else if (slug.contains('carpenter') || slug.contains('wood')) {
      return Icons.carpenter_rounded;
    } else if (slug.contains('clean')) {
      return Icons.cleaning_services_rounded;
    } else if (slug.contains('paint')) {
      return Icons.format_paint_rounded;
    }
    return Icons.handyman_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is Authenticated ? authState.user : null;
    final categoriesAsync = ref.watch(categoriesProvider);
    final citiesAsync = ref.watch(citiesProvider);
    final selectedCity = ref.watch(selectedCityProvider);

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
            tooltip: 'My Profile',
            icon: const Icon(Icons.person_outline_rounded, color: Color(0xFF6366F1)),
            onPressed: () {
              context.push(AppRoutes.customerProfile);
            },
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
              // User Greeting & City Selector Bar
              Container(
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
                          radius: 20,
                          backgroundColor: const Color(0xFF6366F1),
                          child: Text(
                            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'C',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Namaste, ${user?.name.split(" ").first ?? "Customer"}!',
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
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFF334155), height: 1),
                    const SizedBox(height: 12),

                    // City Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: Color(0xFF6366F1), size: 16),
                            SizedBox(width: 4),
                            Text('Operating City:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          ],
                        ),
                        citiesAsync.when(
                          data: (cities) {
                            if (cities.isEmpty) return const Text('Pan-India', style: TextStyle(color: Colors.white, fontSize: 12));
                            final currentCity = selectedCity ?? cities.first;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF475569)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: currentCity.id,
                                  dropdownColor: const Color(0xFF1E293B),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  isDense: true,
                                  items: cities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                                  onChanged: (id) {
                                    if (id != null) {
                                      final chosen = cities.firstWhere((c) => c.id == id);
                                      ref.read(selectedCityProvider.notifier).state = chosen;
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1))),
                          error: (err, st) => const Text('India', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Categories Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Services',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF6366F1), size: 18),
                    onPressed: () {
                      ref.invalidate(categoriesProvider);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Real Categories Grid
              categoriesAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  ),
                ),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, color: Color(0xFFEF4444), size: 36),
                      const SizedBox(height: 8),
                      Text('Could not load categories: $err', style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(categoriesProvider),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                        child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                data: (categoriesList) => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: categoriesList.length,
                  itemBuilder: (context, index) {
                    final cat = categoriesList[index];
                    return Material(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          _showCategoryDetails(context, cat.name, cat.description ?? '', cat.minVisitingCharge);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                                    child: Icon(_getCategoryIcon(cat.slug), color: const Color(0xFF6366F1), size: 20),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'From \u20B9${cat.minVisitingCharge.toStringAsFixed(0)}',
                                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cat.description ?? 'Professional service',
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Marketplace workflow info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF6366F1), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'How Serviqo Works',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _workflowStep('1', 'Describe Problem', 'Select service category and specify the issue.'),
                    _workflowStep('2', 'Select Technicians', 'Compare ratings, experience, and visiting fees.'),
                    _workflowStep('3', 'Technician Accepts & Visits', 'First technician to accept visits for inspection.'),
                    _workflowStep('4', 'Quotation & Payment', 'Approve the itemized quote before repair starts.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, String name, String desc, double visitingCharge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('Visit from \u20B9${visitingCharge.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Service request creation for $name will be available in Phase 7.'),
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Request Technician', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workflowStep(String number, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
            child: Text(number, style: const TextStyle(color: Color(0xFF6366F1), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  TextSpan(text: desc, style: const TextStyle(color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}