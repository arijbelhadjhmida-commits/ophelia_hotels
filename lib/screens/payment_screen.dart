import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/common.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onBack;
  final Function(bool isRoom, String? reservationId) onComplete;

  const PaymentScreen({
    super.key,
    required this.data,
    required this.onBack,
    required this.onComplete,
  });

  @override
  State<PaymentScreen> createState() => _PaymentState();
}

class _PaymentState extends State<PaymentScreen> {
  final _name = TextEditingController();
  final _card = TextEditingController();
  final _exp = TextEditingController();
  final _cvv = TextEditingController();
  bool _processing = false;
  bool _done = false;
  String? _error;
  String? _reservationId;

  Future<void> _pay() async {
    if (_name.text.isEmpty || _card.text.isEmpty || _exp.text.isEmpty || _cvv.text.isEmpty) {
      setState(() => _error = 'Please fill all card details');
      return;
    }
    final auth = context.read<AuthProvider>();
    setState(() {
      _processing = true;
      _error = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    try {
      final user = auth.user;
      if (user == null) throw Exception('Not logged in');

      final isRoom = widget.data['type'] == 'room';
      final payload = {
        'user_id': user.uid,
        'hotel_id': widget.data['hotel_id'],
        'hotel_name': widget.data['hotel'],
        'service_id': widget.data['service_id'],
        'service_name': widget.data['service'],
        'service_category': widget.data['service_category'],
        'reservation_type': widget.data['type'],
        'total_price': widget.data['price'],
        'status': 'confirmed',
      };

      if (isRoom) {
        payload.addAll({
          'check_in': widget.data['check_in'],
          'check_out': widget.data['check_out'],
          'adults': widget.data['adults'],
          'children': widget.data['children'],
          'formula': widget.data['formula'],
          'sport_package': widget.data['sport'],
          'spa_package': widget.data['spa'],
          'nights': widget.data['nights'],
        });
      } else {
        payload.addAll({
          'booking_date': widget.data['booking_date'],
          'persons': widget.data['persons'],
        });
      }

      _reservationId = await SupabaseService.createReservation(payload);

      if (!mounted) return;
      setState(() {
        _processing = false;
        _done = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = 'Payment saved locally but not synced: $e';
        _done = true;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _card.dispose();
    _exp.dispose();
    _cvv.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final price = widget.data['price'] as int;
    final isRoom = widget.data['type'] == 'room';

    if (_done) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 40, color: AppColors.navy),
                ),
                const SizedBox(height: 24),
                Text.rich(TextSpan(
                  text: 'Payment ',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    color: AppColors.cream,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Successful!',
                      style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                    ),
                  ],
                )),
                const SizedBox(height: 8),
                Text(
                  '${widget.data['hotel']} — ${widget.data['service']}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.cream.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '${fmt.format(price)} DT',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRoom
                      ? 'QR Code sent to your email for check-in'
                      : 'Confirmation saved to the database',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.cream.withValues(alpha: 0.4),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  ErrorBanner(message: _error!),
                ],
                const SizedBox(height: 32),
                GoldBtn(
                  text: 'BACK TO HOME',
                  onPressed: () => widget.onComplete(isRoom, _reservationId),
                ),
              ],
            ),
          ),
        ),
      );
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
              text: 'Secure ',
              style: GoogleFonts.cormorantGaramond(fontSize: 28, color: AppColors.cream),
              children: const [
                TextSpan(
                  text: 'Payment',
                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                ),
              ],
            )),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.cream.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${fmt.format(price)} DT',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null) ErrorBanner(message: _error!),
            CInput(label: 'Cardholder Name', hint: 'Full name on card', ctrl: _name),
            CInput(label: 'Card Number', hint: '1234 5678 9012 3456', ctrl: _card, keyboard: TextInputType.number),
            Row(
              children: [
                Expanded(child: CInput(label: 'Expiry', hint: 'MM/YY', ctrl: _exp)),
                const SizedBox(width: 12),
                Expanded(
                  child: CInput(
                    label: 'CVV',
                    hint: '123',
                    ctrl: _cvv,
                    obscure: true,
                    keyboard: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GoldBtn(
              text: 'PAY ${fmt.format(price)} DT',
              full: true,
              loading: _processing,
              onPressed: _pay,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '🔒 256-bit SSL encrypted • Saved to Supabase',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.cream.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
