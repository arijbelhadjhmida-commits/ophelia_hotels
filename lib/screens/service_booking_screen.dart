import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../widgets/common.dart';

class ServiceBookingScreen extends StatefulWidget {
  final HotelModel hotel;
  final ServiceModel service;
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onPay;

  const ServiceBookingScreen({
    super.key,
    required this.hotel,
    required this.service,
    required this.onBack,
    required this.onPay,
  });

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingState();
}

class _ServiceBookingState extends State<ServiceBookingScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  int _pers = 1;
  DateTime? _date;
  bool _initialized = false;

  int get _total => widget.service.price * _pers;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (!_initialized && user != null) {
      _first.text = user.firstName;
      _last.text = user.lastName;
      _initialized = true;
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.gold),
              label: Text('Back', style: GoogleFonts.dmSans(color: AppColors.gold)),
            ),
            const SizedBox(height: 8),
            Text.rich(TextSpan(
              text: 'Book ',
              style: GoogleFonts.cormorantGaramond(fontSize: 28, color: AppColors.cream),
              children: const [
                TextSpan(
                  text: 'Service',
                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                ),
              ],
            )),
            Text(
              '${widget.hotel.name} — ${widget.service.name}',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.cream.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: CInput(label: 'First Name', hint: 'First name', ctrl: _first)),
                const SizedBox(width: 12),
                Expanded(child: CInput(label: 'Last Name', hint: 'Last name', ctrl: _last)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERSONS',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16, color: AppColors.gold),
                        onPressed: () => setState(() => _pers = (_pers - 1).clamp(1, 20)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      Text(
                        '$_pers',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cream,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16, color: AppColors.gold),
                        onPressed: () => setState(() => _pers = (_pers + 1).clamp(1, 20)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _date = d);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATE',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _date != null
                              ? DateFormat('dd/MM/yyyy').format(_date!)
                              : 'Select date',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: _date != null
                                ? AppColors.cream
                                : AppColors.cream.withValues(alpha: 0.3),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.gold.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total ($_pers pers.)',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.cream.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(_total)} DT',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GoldBtn(
              text: 'PROCEED TO PAYMENT',
              full: true,
              onPressed: (_first.text.isNotEmpty && _date != null)
                  ? () => widget.onPay({
                        'type': 'service',
                        'hotel': widget.hotel.name,
                        'hotel_id': widget.hotel.id,
                        'service': widget.service.name,
                        'service_id': widget.service.id,
                        'service_category': widget.service.category,
                        'price': _total,
                        'persons': _pers,
                        'booking_date': DateFormat('yyyy-MM-dd').format(_date!),
                      })
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }
}
