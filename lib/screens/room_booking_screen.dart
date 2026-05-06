import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class RoomBookingScreen extends StatefulWidget {
  final HotelModel hotel;
  final ServiceModel service;
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onPay;

  const RoomBookingScreen({
    super.key,
    required this.hotel,
    required this.service,
    required this.onBack,
    required this.onPay,
  });

  @override
  State<RoomBookingScreen> createState() => _RoomBookingState();
}

class _RoomBookingState extends State<RoomBookingScreen> {
  DateTime? _ci, _co;
  int _adults = 2, _children = 0;
  String _formula = 'All Inclusive';
  bool _sport = false, _spa = false;

  int get _nights => (_ci != null && _co != null) ? _co!.difference(_ci!).inDays : 0;
  int get _pers => _adults + _children;
  int get _fPrice => AppConst.formulaPrices[_formula] ?? 0;
  int get _total => PriceCalc.roomTotal(
        perNight: widget.service.price,
        nights: _nights,
        adults: _adults,
        children: _children,
        formula: _formula,
        sport: _sport,
        spa: _spa,
      );

  void _pay() {
    if (_nights <= 0) return;
    widget.onPay({
      'type': 'room',
      'hotel': widget.hotel.name,
      'hotel_id': widget.hotel.id,
      'service': widget.service.name,
      'service_id': widget.service.id,
      'service_category': widget.service.category,
      'price': _total,
      'check_in': DateFormat('yyyy-MM-dd').format(_ci!),
      'check_out': DateFormat('yyyy-MM-dd').format(_co!),
      'adults': _adults,
      'children': _children,
      'formula': _formula,
      'sport': _sport,
      'spa': _spa,
      'nights': _nights,
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
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
                  text: 'Room',
                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                ),
              ],
            )),
            const SizedBox(height: 4),
            Text(
              '${widget.hotel.name} — ${widget.service.name} — ${fmt.format(widget.service.price)} DT/night',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.cream.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _dateBtn('Check-in', _ci, () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => _ci = d);
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateBtn('Check-out', _co, () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _ci?.add(const Duration(days: 1)) ??
                          DateTime.now().add(const Duration(days: 2)),
                      firstDate: _ci?.add(const Duration(days: 1)) ??
                          DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) setState(() => _co = d);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _counter('Adults', _adults, (v) => setState(() => _adults = v.clamp(1, 10))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _counter('Children', _children, (v) => setState(() => _children = v.clamp(0, 10))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'FORMULA',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConst.formulaPrices.keys.map((f) => ChoiceChip(
                    label: Text(
                      f,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: _formula == f
                            ? AppColors.navy
                            : AppColors.cream.withValues(alpha: 0.7),
                      ),
                    ),
                    selected: _formula == f,
                    selectedColor: AppColors.gold,
                    backgroundColor: AppColors.blue.withValues(alpha: 0.3),
                    onSelected: (_) => setState(() => _formula = f),
                  )).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'EXTRA SERVICES',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            _check('Sport Activities (+800 DT/pers)', _sport, (v) => setState(() => _sport = v)),
            _check('Spa & Wellness (+1,200 DT/pers)', _spa, (v) => setState(() => _spa = v)),
            if (_nights > 0) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    Text(
                      'PRICE SUMMARY',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _pLine(
                      'Room ($_nights nights × ${fmt.format(widget.service.price)} DT)',
                      fmt.format(_nights * widget.service.price),
                    ),
                    if (_fPrice > 0)
                      _pLine(
                        '$_formula (${_nights}n × ${_pers}p × $_fPrice DT)',
                        fmt.format(_nights * _pers * _fPrice),
                      ),
                    if (_sport) _pLine('Sport ($_pers pers × 800 DT)', fmt.format(_pers * 800)),
                    if (_spa) _pLine('Spa ($_pers pers × 1,200 DT)', fmt.format(_pers * 1200)),
                    const Divider(color: AppColors.gold, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${fmt.format(_total)} DT',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            GoldBtn(
              text: 'PROCEED TO PAYMENT — ${fmt.format(_total)} DT',
              full: true,
              onPressed: _nights > 0 ? _pay : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBtn(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
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
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: date != null
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
    );
  }

  Widget _counter(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
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
                onPressed: () => onChanged(value - 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Text(
                '$value',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16, color: AppColors.gold),
                onPressed: () => onChanged(value + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.gold : AppColors.cream.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: value ? AppColors.gold : Colors.transparent,
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: AppColors.navy)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.cream)),
          ],
        ),
      ),
    );
  }

  Widget _pLine(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.cream.withValues(alpha: 0.6),
              ),
            ),
          ),
          Text(
            '$amount DT',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
          ),
        ],
      ),
    );
  }
}
