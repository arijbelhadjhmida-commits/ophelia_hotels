import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import '../providers/hotel_provider.dart';

class HomeScreen extends StatelessWidget {
  final Function(HotelModel)? onSelectHotel;
  final VoidCallback? onMyStay;

  const HomeScreen({super.key, this.onSelectHotel, this.onMyStay});

  @override
  Widget build(BuildContext context) {
    final hotels = context.watch<HotelProvider>().hotels;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.gold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(TextSpan(
                    text: 'OPHELIA ',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      color: AppColors.cream,
                      letterSpacing: 4,
                    ),
                    children: const [
                      TextSpan(
                        text: 'HOTELS',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 8),
                  Text(
                    'Where Luxury Meets Timeless Elegance',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppColors.cream.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'OUR COLLECTION',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.gold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(TextSpan(
                  text: 'Discover Our ',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    color: AppColors.navy,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Establishments',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 24),
                ...hotels.map((h) => HotelCard(hotel: h, onTap: () => onSelectHotel?.call(h))),
              ],
            ),
          ),
          if (onMyStay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: onMyStay,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.green.withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ACTIVE STAY',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.green,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text.rich(TextSpan(
                              text: 'Access Your ',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 20,
                                color: AppColors.cream,
                                fontWeight: FontWeight.w600,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Smart Room',
                                  style: TextStyle(color: AppColors.gold),
                                ),
                              ],
                            )),
                            const SizedBox(height: 4),
                            Text(
                              'Room 312',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.cream.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gold, AppColors.darkGold],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.arrow_forward, color: AppColors.navy),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
            ),
            child: Column(
              children: [
                Text(
                  '"Ophelia Hotels – Experience where comfort meets elegance and luxury knows no limits"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    color: AppColors.cream,
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                Container(width: 60, height: 2, color: AppColors.gold),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            color: AppColors.navy,
            child: Column(
              children: [
                Text(
                  'Contact Us',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                for (final t in [
                  '📧 ophelia.hotels@gmail.com',
                  '🌐 www.OpheliaHotels.com',
                  '📞 +216 71 000 000'
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      t,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.cream.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  '© 2026 Ophelia Hotels — All Rights Reserved',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.cream.withValues(alpha: 0.2),
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

class HotelCard extends StatelessWidget {
  final HotelModel hotel;
  final VoidCallback onTap;

  const HotelCard({super.key, required this.hotel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cover = hotel.coverImage;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue]),
              ),
              child: Stack(
                children: [
                  if (cover != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.asset(
                          cover,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.navy.withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '★ ${hotel.rating}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.name,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cream,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '📍 ${hotel.location}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.cream.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    hotel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.blue,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'EXPLORE →',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
