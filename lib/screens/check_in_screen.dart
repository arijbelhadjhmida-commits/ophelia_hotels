import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/smart_room_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/common.dart';

class CheckInScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const CheckInScreen({super.key, required this.onComplete});

  @override
  State<CheckInScreen> createState() => _CheckInState();
}

class _CheckInState extends State<CheckInScreen> {
  bool _scanning = false;
  bool _done = false;
  String? _error;

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _error = null;
    });

    final auth = context.read<AuthProvider>();
    final smart = context.read<SmartRoomProvider>();

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    try {
      final user = auth.user;
      if (user == null) throw Exception('Not logged in');

      final smartRoomId = await SupabaseService.activateSmartRoom({
        'user_id': user.uid,
        'reservation_id': auth.activeReservationId,
        'room_number': '312',
        'hotel_name': auth.activeHotelName ?? 'Ophelia Hotel',
        'light_on': smart.lightOn,
        'temperature': smart.temperature,
        'blinds_open': smart.blindsOpen,
        'mode': smart.mode,
        'is_active': true,
      });

      smart.setSmartRoomId(smartRoomId);

      if (auth.activeReservationId != null) {
        await SupabaseService.updateReservationStatus(auth.activeReservationId!, 'active');
      }

      if (!mounted) return;
      setState(() {
        _scanning = false;
        _done = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = 'Failed to activate smart room: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      final hotelName = context.read<AuthProvider>().activeHotelName ?? 'Ophelia Hotel';
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
                child: const Icon(Icons.check, size: 40, color: AppColors.navy),
              ),
              const SizedBox(height: 24),
              Text.rich(TextSpan(
                text: 'Check-In ',
                style: GoogleFonts.cormorantGaramond(fontSize: 26, color: AppColors.cream),
                children: const [
                  TextSpan(
                    text: 'Successful!',
                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                  ),
                ],
              )),
              const SizedBox(height: 8),
              Text(
                'Room 312 — $hotelName',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Smart Room activated. Data synced to admin.',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.cream.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 32),
              GoldBtn(text: 'ENTER MY STAY', onPressed: widget.onComplete),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(TextSpan(
                text: 'Scan ',
                style: GoogleFonts.cormorantGaramond(fontSize: 26, color: AppColors.cream),
                children: const [
                  TextSpan(
                    text: 'QR Code',
                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                  ),
                ],
              )),
              const SizedBox(height: 8),
              Text(
                'Position your QR Code from reception',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.cream.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: _scanning
                      ? const CircularProgressIndicator(color: AppColors.gold)
                      : Icon(
                          Icons.qr_code_scanner,
                          size: 80,
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                ),
              ),
              const SizedBox(height: 28),
              if (_error != null) ErrorBanner(message: _error!),
              if (_scanning)
                Text(
                  'Scanning...',
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
      ),
    );
  }
}
