import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart';
import 'admin_dashboard.dart';
import 'check_in_screen.dart';
import 'check_out_screen.dart';
import 'home_screen.dart';
import 'hotel_detail_screen.dart';
import 'payment_screen.dart';
import 'room_booking_screen.dart';
import 'service_booking_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'smart_room_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  String _screen = 'home';
  HotelModel? _hotel;
  ServiceModel? _service;
  Map<String, dynamic>? _payData;

  void _go(String s) => setState(() => _screen = s);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_screen == 'admin') {
      return AdminDashboard(
        onSignOut: () async {
          await auth.signOut();
          _go('home');
        },
      );
    }

    final isFullscreen = const {'smartroom', 'checkin', 'checkout'}.contains(_screen);

    return Scaffold(
      appBar: isFullscreen
          ? null
          : AppBar(
              title: GestureDetector(
                onTap: () => _go('home'),
                child: Text.rich(TextSpan(
                  text: 'OPHELIA ',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                  children: const [
                    TextSpan(text: 'HOTELS', style: TextStyle(color: AppColors.gold)),
                  ],
                )),
              ),
              actions: [
                if (_screen != 'home')
                  TextButton(
                    onPressed: () => _go('home'),
                    child: Text(
                      'Home',
                      style: GoogleFonts.dmSans(
                        color: AppColors.cream.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                if (auth.isLoggedIn && auth.hasActiveStay)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: TextButton(
                      onPressed: () => _go('checkin'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'My Stay',
                          style: GoogleFonts.dmSans(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (auth.isLoggedIn)
                  PopupMenuButton<String>(
                    icon: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.gold,
                      child: Text(
                        auth.user!.firstName.isNotEmpty ? auth.user!.firstName[0] : '?',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    onSelected: (v) async {
                      if (v == 'out') {
                        await auth.signOut();
                        if (!mounted) return;
                        _go('home');
                      } else if (v == 'admin') {
                        _go('admin');
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Text(
                          auth.user!.firstName,
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (auth.isAdmin)
                        const PopupMenuItem(value: 'admin', child: Text('Admin Panel')),
                      const PopupMenuItem(value: 'out', child: Text('Sign Out')),
                    ],
                  )
                else ...[
                  TextButton(
                    onPressed: () => _go('signin'),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.dmSans(color: AppColors.cream, fontSize: 13),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () => _go('signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
      body: _buildScreen(auth),
    );
  }

  Widget _buildScreen(AuthProvider auth) {
    switch (_screen) {
      case 'home':
        return HomeScreen(
          onSelectHotel: (h) {
            _hotel = h;
            _go('hotel');
          },
          onMyStay: auth.hasActiveStay ? () => _go('checkin') : null,
        );
      case 'signin':
        return SignInScreen(
          onSuccess: () => _go('home'),
          onGoSignUp: () => _go('signup'),
          onAdminSuccess: () => _go('admin'),
        );
      case 'signup':
        return SignUpScreen(
          onSuccess: () => _go('home'),
          onGoSignIn: () => _go('signin'),
        );
      case 'hotel':
        return HotelDetailScreen(
          hotel: _hotel!,
          onBack: () => _go('home'),
          onBookRoom: (s) {
            _service = s;
            auth.isLoggedIn ? _go('roombook') : _go('signup');
          },
          onBookService: (s) {
            _service = s;
            auth.isLoggedIn ? _go('servicebook') : _go('signup');
          },
        );
      case 'roombook':
        return RoomBookingScreen(
          hotel: _hotel!,
          service: _service!,
          onBack: () => _go('hotel'),
          onPay: (d) {
            _payData = d;
            _go('payment');
          },
        );
      case 'servicebook':
        return ServiceBookingScreen(
          hotel: _hotel!,
          service: _service!,
          onBack: () => _go('hotel'),
          onPay: (d) {
            _payData = d;
            _go('payment');
          },
        );
      case 'payment':
        return PaymentScreen(
          data: _payData!,
          onBack: () => _go(_payData?['type'] == 'room' ? 'roombook' : 'servicebook'),
          onComplete: (isRoom, reservationId) {
            if (isRoom) {
              auth.setActiveStay(
                true,
                reservationId: reservationId,
                hotelName: _payData?['hotel'] as String?,
              );
            }
            _go('home');
          },
        );
      case 'checkin':
        return CheckInScreen(onComplete: () => _go('smartroom'));
      case 'smartroom':
        return SmartRoomScreen(onCheckout: () => _go('checkout'));
      case 'checkout':
        return CheckOutScreen(
          onComplete: () {
            auth.setActiveStay(false);
            _go('home');
          },
        );
      default:
        return HomeScreen(onSelectHotel: (h) {
          _hotel = h;
          _go('hotel');
        });
    }
  }
}
