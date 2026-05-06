import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class HotelDetailScreen extends StatelessWidget {
  final HotelModel hotel;
  final VoidCallback onBack;
  final Function(ServiceModel) onBookRoom;
  final Function(ServiceModel) onBookService;

  const HotelDetailScreen({
    super.key,
    required this.hotel,
    required this.onBack,
    required this.onBookRoom,
    required this.onBookService,
  });

  void _showService(BuildContext context, ServiceModel s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cream.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: s.imageAsset != null
                    ? Image.asset(
                        s.imageAsset!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(s),
                      )
                    : _placeholder(s),
              ),
              const SizedBox(height: 16),
              Text(
                s.name,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.description,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.cream.withValues(alpha: 0.7),
                  height: 1.6,
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
                      s.isRoom ? 'Per night' : 'Per person',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.cream.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(s.price)} DT',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GoldBtn(
                text: 'BOOK NOW',
                full: true,
                onPressed: () {
                  Navigator.pop(context);
                  s.isRoom ? onBookRoom(s) : onBookService(s);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ServiceModel s) {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.blue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(s.categoryIcon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              s.name,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                color: AppColors.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cover = hotel.coverImage;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 240,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
                ),
                child: cover != null
                    ? Image.asset(
                        cover,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      )
                    : null,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.navy,
                        AppColors.navy.withValues(alpha: 0.4),
                        AppColors.navy.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: AppColors.cream),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.navy.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '★ ${hotel.rating}/5',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hotel.name,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      '📍 ${hotel.location}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.cream.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.blue,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 24),
                Text.rich(TextSpan(
                  text: 'Services & ',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    color: AppColors.navy,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Gallery',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 4),
                Text(
                  'Click any service to view details and book',
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.bronze),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: hotel.services.length,
                  itemBuilder: (_, i) =>
                      _ServiceCard(service: hotel.services[i], onTap: () => _showService(context, hotel.services[i])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final img = service.imageAsset;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue]),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              if (img != null)
                Positioned.fill(
                  child: Image.asset(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.navy.withValues(alpha: 0.9),
                        AppColors.navy.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: service.isRoom ? AppColors.gold : AppColors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    service.priceLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  service.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
