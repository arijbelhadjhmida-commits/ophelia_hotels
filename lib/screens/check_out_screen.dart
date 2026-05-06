import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/smart_room_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/common.dart';

class CheckOutScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const CheckOutScreen({super.key, required this.onComplete});

  @override
  State<CheckOutScreen> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOutScreen> {
  bool _scanning = false;
  bool _done = false;
  String? _error;

  Future<void> _scan() async {
    final auth = context.read<AuthProvider>();
    final smart = context.read<SmartRoomProvider>();

    setState(() {
      _scanning = true;
      _error = null;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      if (smart.smartRoomId != null) {
        await SupabaseService.deactivateSmartRoom(smart.smartRoomId!);
      }
      if (auth.activeReservationId != null) {
        await SupabaseService.updateReservationStatus(auth.activeReservationId!, 'completed');
      }
      smart.reset();

      if (!mounted) return;
      setState(() {
        _scanning = false;
        _done = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = 'Checkout sync failed: $e';
        _done = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
        ),
        child: Center(
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
                child: const Center(
                  child: Text('👋', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Thank You!',
                style: GoogleFonts.cormorantGaramond(fontSize: 26, color: AppColors.cream),
              ),
              const SizedBox(height: 8),
              Text(
                'Check-out complete',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.cream.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Smart Room access deactivated. See you again!',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.cream.withValues(alpha: 0.3),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ErrorBanner(message: _error!),
                ),
              ],
              const SizedBox(height: 32),
              GoldBtn(text: 'BACK TO HOME', onPressed: widget.onComplete),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Check-Out',
              style: GoogleFonts.cormorantGaramond(fontSize: 26, color: AppColors.cream),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan QR Code at reception',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.cream.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 32),
            if (_scanning)
              Text(
                'Processing...',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              )
            else
              GoldBtn(text: 'SCAN QR CODE', onPressed: _scan),
          ],
        ),
      ),
    );
  }
}
