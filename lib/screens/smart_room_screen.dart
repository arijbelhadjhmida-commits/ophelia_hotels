import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/smart_room_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/common.dart';

class SmartRoomScreen extends StatelessWidget {
  final VoidCallback onCheckout;
  const SmartRoomScreen({super.key, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hotelName = auth.activeHotelName ?? 'Ophelia Hotel';

    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4ADE80)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ACTIVE',
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4ADE80),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Room 312',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cream,
                          ),
                        ),
                        Text(
                          hotelName,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: AppColors.cream.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Smart Stay',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          'Live sync',
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            color: AppColors.cream.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text.rich(TextSpan(
                text: 'Smart ',
                style: GoogleFonts.cormorantGaramond(
                    fontSize: 26, color: AppColors.cream),
                children: const [
                  TextSpan(
                    text: 'Room',
                    style: TextStyle(
                        color: AppColors.gold, fontWeight: FontWeight.w700),
                  ),
                ],
              )),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  labelColor: AppColors.navy,
                  unselectedLabelColor: AppColors.cream.withValues(alpha: 0.5),
                  labelStyle: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w600),
                  dividerHeight: 0,
                  tabs: const [
                    Tab(text: 'Room Control'),
                    Tab(text: 'Schedule'),
                    Tab(text: 'Room Service'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: TabBarView(
                  children: [_ControlTab(), _ScheduleTab(), _ServiceTab()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: GoldBtn(
                  text: 'CHECK-OUT',
                  outline: true,
                  full: true,
                  onPressed: onCheckout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlTab extends StatelessWidget {
  const _ControlTab();

  @override
  Widget build(BuildContext context) {
    final r = context.watch<SmartRoomProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.cream.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${r.temperature}°C',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 38,
                        fontWeight: FontWeight.w200,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _TBtn(Icons.remove, () => r.setTemp(r.temperature - 1)),
                    const SizedBox(width: 8),
                    _TBtn(Icons.add, () => r.setTemp(r.temperature + 1)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Toggle('Lighting', r.lightOn ? 'On' : 'Off', r.lightOn,
              (_) => r.toggleLight()),
          _Toggle('Blinds', r.blindsOpen ? 'Open' : 'Closed', r.blindsOpen,
              (_) => r.toggleBlinds()),
          const SizedBox(height: 16),
          Text(
            'INTELLIGENT MODES',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final m in const [
                ('🌙', 'Night', 'night'),
                ('😴', 'Sleep', 'sleep'),
                ('💼', 'Work', 'work'),
              ]) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => r.setMode(m.$3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: r.mode == m.$3
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : AppColors.navy,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: r.mode == m.$3
                              ? AppColors.gold
                              : AppColors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(m.$1, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            m.$2,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: r.mode == m.$3
                                  ? AppColors.gold
                                  : AppColors.cream.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (m.$3 != 'work') const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            color: AppColors.navy,
          ),
          child: Icon(icon, size: 18, color: AppColors.gold),
        ),
      );
}

class _Toggle extends StatelessWidget {
  final String label, sub;
  final bool val;
  final ValueChanged<bool> onChanged;
  const _Toggle(this.label, this.sub, this.val, this.onChanged);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: val
                ? AppColors.gold.withValues(alpha: 0.2)
                : AppColors.blue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.cream)),
                Text(
                  sub,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: val
                        ? AppColors.gold
                        : AppColors.cream.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            Switch(
                value: val,
                onChanged: onChanged,
                activeThumbColor: AppColors.gold),
          ],
        ),
      );
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    const events = [
      ('🍳', 'Breakfast Buffet', 'Main Hall', '07:00–10:30'),
      ('💆', 'Spa & Wellness', 'Level -1', '10:00–18:00'),
      ('🏊', 'Pool Bar', 'Rooftop', '12:00–15:00'),
      ('🍽️', 'À La Carte Dinner', 'Le Rivage', '19:00–22:00'),
      ('🎵', 'Live Music', 'Beach Lounge', '21:00–01:00'),
    ];
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final e = events[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Text(e.$1, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.$2,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.cream,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      e.$3,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: AppColors.cream.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                e.$4,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceTab extends StatefulWidget {
  const _ServiceTab();
  @override
  State<_ServiceTab> createState() => _ServiceTabState();
}

class _ServiceTabState extends State<_ServiceTab> {
  String? _sel;
  final _subject = TextEditingController();
  final _details = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _subject.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _send(String type,
      {String? subject, String? details, Map<String, dynamic>? meta}) async {
    final auth = context.read<AuthProvider>();
    final smart = context.read<SmartRoomProvider>();
    final user = auth.user;
    if (user == null) return;

    setState(() => _sending = true);
    try {
      await SupabaseService.createRoomServiceRequest({
        'user_id': user.uid,
        'reservation_id': auth.activeReservationId,
        'smart_room_id': smart.smartRoomId,
        'request_type': type,
        'subject': subject,
        'details': details,
        'meta': meta,
        'status': 'pending',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${type[0].toUpperCase()}${type.substring(1)} request sent!'),
          backgroundColor: AppColors.navy,
        ),
      );
      _subject.clear();
      _details.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              for (final s in const [
                ('🧹', 'Cleaning', 'cleaning'),
                ('📋', 'Complaint', 'complaint'),
                ('🍽️', 'Food', 'food_order'),
              ]) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _sel = s.$3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _sel == s.$3
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : AppColors.navy,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _sel == s.$3
                              ? AppColors.gold
                              : AppColors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(s.$1, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            s.$2,
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _sel == s.$3
                                  ? AppColors.gold
                                  : AppColors.cream.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (s.$3 != 'food_order') const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (_sel == 'cleaning')
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  const Text('🧹', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text(
                    'Request Cleaning',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Housekeeping will arrive shortly',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.cream.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GoldBtn(
                    text: 'REQUEST NOW',
                    loading: _sending,
                    onPressed: () =>
                        _send('cleaning', subject: 'Cleaning request'),
                  ),
                ],
              ),
            ),
          if (_sel == 'complaint')
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit Complaint',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CInput(
                      label: 'Subject',
                      hint: 'Brief description',
                      ctrl: _subject),
                  Text(
                    'DETAILS',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _details,
                    maxLines: 3,
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.cream),
                    decoration: InputDecoration(
                      hintText: 'Describe your issue...',
                      hintStyle: GoogleFonts.dmSans(
                          color: AppColors.cream.withValues(alpha: 0.3)),
                      filled: true,
                      fillColor: AppColors.blue.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.gold.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GoldBtn(
                    text: 'SUBMIT',
                    full: true,
                    loading: _sending,
                    onPressed: () => _send(
                      'complaint',
                      subject: _subject.text,
                      details: _details.text,
                    ),
                  ),
                ],
              ),
            ),
          if (_sel == 'food_order')
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Digital Menu',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final cat in const [
                    (
                      'STARTERS',
                      [
                        ('Caesar Salad', '28 DT'),
                        ('Soup of the Day', '22 DT'),
                        ('Bruschetta', '25 DT')
                      ]
                    ),
                    (
                      'MAIN COURSE',
                      [
                        ('Grilled Sea Bass', '65 DT'),
                        ('Lamb Tagine', '58 DT'),
                        ('Steak & Fries', '72 DT')
                      ]
                    ),
                    (
                      'DESSERTS',
                      [
                        ('Crème Brûlée', '30 DT'),
                        ('Chocolate Fondant', '35 DT')
                      ]
                    ),
                    (
                      'BEVERAGES',
                      [('Fresh Juice', '15 DT'), ('Smoothie', '22 DT')]
                    ),
                  ]) ...[
                    Text(
                      cat.$1,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final item in cat.$2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.$1,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: AppColors.cream),
                            ),
                            Row(
                              children: [
                                Text(
                                  item.$2,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.gold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.add,
                                      size: 14, color: AppColors.gold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                  GoldBtn(
                    text: 'ORDER NOW',
                    full: true,
                    loading: _sending,
                    onPressed: () => _send(
                      'food_order',
                      subject: 'Room service order',
                      details: 'Menu order from Smart Room',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
