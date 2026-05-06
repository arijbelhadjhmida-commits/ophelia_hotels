import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../services/supabase_service.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback onSignOut;
  const AdminDashboard({super.key, required this.onSignOut});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _reservations = [];
  List<Map<String, dynamic>> _smartRooms = [];
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        SupabaseService.getAdminStats(),
        SupabaseService.getAllReservations(),
        SupabaseService.getAllActiveSmartRooms(),
        SupabaseService.getAllRoomServiceRequests(),
        SupabaseService.getAllProfiles(),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _reservations = results[1] as List<Map<String, dynamic>>;
        _smartRooms = results[2] as List<Map<String, dynamic>>;
        _requests = results[3] as List<Map<String, dynamic>>;
        _users = results[4] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load admin data: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          title: Text.rich(TextSpan(
            text: 'ADMIN ',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.cream,
            ),
            children: const [
              TextSpan(text: 'PANEL', style: TextStyle(color: AppColors.gold)),
            ],
          )),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.gold),
              onPressed: _load,
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.cream),
              onPressed: widget.onSignOut,
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Reservations'),
              Tab(text: 'Smart Rooms'),
              Tab(text: 'Requests'),
              Tab(text: 'Users'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    children: [
                      _OverviewTab(stats: _stats!),
                      _ReservationsTab(items: _reservations, onRefresh: _load),
                      _SmartRoomsTab(items: _smartRooms),
                      _RequestsTab(items: _requests, onRefresh: _load),
                      _UsersTab(items: _users),
                    ],
                  ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _OverviewTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final tiles = [
      ('Total Reservations', '${stats['total_reservations'] ?? 0}', Icons.event_available, AppColors.navy),
      ('Active Stays', '${stats['active_stays'] ?? 0}', Icons.bedroom_parent, AppColors.green),
      ('Pending Requests', '${stats['pending_requests'] ?? 0}', Icons.notifications_active, AppColors.darkGold),
      ('Registered Users', '${stats['total_users'] ?? 0}', Icons.people, AppColors.blue),
      ('Total Revenue', '${fmt.format(stats['total_revenue'] ?? 0)} DT', Icons.payments, AppColors.gold),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: tiles.length,
        itemBuilder: (_, i) {
          final t = tiles[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(t.$3, color: t.$4, size: 28),
                Text(
                  t.$1,
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.bronze),
                ),
                Text(
                  t.$2,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReservationsTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback onRefresh;
  const _ReservationsTab({required this.items, required this.onRefresh});

  Color _statusColor(String? s) {
    switch (s) {
      case 'active':
        return AppColors.green;
      case 'completed':
        return AppColors.bronze;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.darkGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No reservations yet'));
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final r = items[i];
          final profile = r['profiles'] as Map<String, dynamic>?;
          final fullName = profile == null
              ? 'Unknown'
              : '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${r['hotel_name'] ?? '—'} — ${r['service_name'] ?? '—'}',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(r['status'] as String?).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${r['status'] ?? 'pending'}'.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(r['status'] as String?),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  fullName.isEmpty ? 'Unknown' : fullName,
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.bronze),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r['reservation_type'] == 'room'
                          ? '${r['check_in'] ?? ''} → ${r['check_out'] ?? ''}'
                          : '${r['booking_date'] ?? ''} (${r['persons'] ?? 0} pers.)',
                      style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.navy.withValues(alpha: 0.6)),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(r['total_price'] ?? 0)} DT',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SmartRoomsTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _SmartRoomsTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No active smart rooms'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = items[i];
        final profile = r['profiles'] as Map<String, dynamic>?;
        final fullName = profile == null
            ? 'Unknown'
            : '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Room ${r['room_number'] ?? '—'} — ${r['hotel_name'] ?? '—'}',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                fullName.isEmpty ? 'Unknown guest' : fullName,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.cream.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  _chip('🌡️ ${r['temperature'] ?? '—'}°C'),
                  _chip('💡 ${(r['light_on'] ?? false) ? 'On' : 'Off'}'),
                  _chip('🪟 ${(r['blinds_open'] ?? false) ? 'Open' : 'Closed'}'),
                  _chip('🎛️ ${r['mode'] ?? 'normal'}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _RequestsTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VoidCallback onRefresh;
  const _RequestsTab({required this.items, required this.onRefresh});

  String _icon(String? type) {
    switch (type) {
      case 'cleaning':
        return '🧹';
      case 'complaint':
        return '📋';
      case 'food_order':
        return '🍽️';
      default:
        return '🔔';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No service requests'));
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final r = items[i];
          final profile = r['profiles'] as Map<String, dynamic>?;
          final fullName = profile == null
              ? 'Unknown'
              : '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
          final status = r['status'] as String? ?? 'pending';
          final isPending = status == 'pending';
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPending ? AppColors.gold : AppColors.cream,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_icon(r['request_type'] as String?), style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${r['request_type'] ?? 'request'}'.replaceAll('_', ' ').toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            fullName.isEmpty ? 'Unknown guest' : fullName,
                            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.bronze),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPending ? AppColors.gold : AppColors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isPending ? AppColors.navy : AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                if ((r['subject'] as String?)?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(
                    r['subject'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.navy,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if ((r['details'] as String?)?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    r['details'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.navy.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await SupabaseService.updateRequestStatus(r['id'] as String, 'completed');
                            onRefresh();
                          },
                          child: const Text('Mark Completed'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            await SupabaseService.updateRequestStatus(r['id'] as String, 'cancelled');
                            onRefresh();
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _UsersTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No users registered'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final u = items[i];
        final initial = ((u['first_name'] as String?) ?? '?').isNotEmpty
            ? (u['first_name'] as String)[0].toUpperCase()
            : '?';
        final isAdmin = u['is_admin'] == true;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isAdmin ? AppColors.navy : AppColors.gold,
            child: Text(
              initial,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: isAdmin ? AppColors.gold : AppColors.navy,
              ),
            ),
          ),
          title: Text(
            '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim(),
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('CIN: ${u['cin'] ?? '—'}'),
          trailing: isAdmin
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ADMIN',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
