import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../widgets/common.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onGoSignIn;

  const SignUpScreen({
    super.key,
    required this.onSuccess,
    required this.onGoSignIn,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _cin = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _addr = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  DateTime? _dob;
  String? _localError;

  Future<void> _submit() async {
    setState(() => _localError = null);
    if (_cin.text.isEmpty ||
        _first.text.isEmpty ||
        _last.text.isEmpty ||
        _pw.text.isEmpty ||
        _dob == null ||
        _addr.text.isEmpty) {
      setState(() => _localError = 'Please fill all fields');
      return;
    }
    if (_pw.text != _pw2.text) {
      setState(() => _localError = 'Passwords do not match');
      return;
    }
    if (_pw.text.length < 5) {
      setState(() => _localError = 'Password must be at least 5 characters');
      return;
    }

    final ok = await context.read<AuthProvider>().signUp(
          cin: _cin.text.trim(),
          firstName: _first.text.trim(),
          lastName: _last.text.trim(),
          address: _addr.text.trim(),
          dob: _dob!,
          password: _pw.text,
        );
    if (!mounted) return;
    if (ok) widget.onSuccess();
  }

  void _reset() {
    _cin.clear();
    _first.clear();
    _last.clear();
    _addr.clear();
    _pw.clear();
    _pw2.clear();
    setState(() {
      _dob = null;
      _localError = null;
    });
  }

  @override
  void dispose() {
    _cin.dispose();
    _first.dispose();
    _last.dispose();
    _addr.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final errorMsg = _localError ?? auth.error;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(
                  text: 'Create ',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    color: AppColors.cream,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Account',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 4),
                Text(
                  'Join Ophelia Hotels',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.cream.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 24),
                if (errorMsg != null) ErrorBanner(message: errorMsg),
                CInput(label: 'CIN', hint: 'CIN Number (unique)', ctrl: _cin),
                Row(children: [
                  Expanded(child: CInput(label: 'First Name', hint: 'First name', ctrl: _first)),
                  const SizedBox(width: 12),
                  Expanded(child: CInput(label: 'Last Name', hint: 'Last name', ctrl: _last)),
                ]),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _dob = d);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dob != null
                              ? DateFormat('dd/MM/yyyy').format(_dob!)
                              : 'Date of Birth',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: _dob != null
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
                ),
                CInput(label: 'Address', hint: 'Full address', ctrl: _addr),
                Row(children: [
                  Expanded(child: CInput(label: 'Password', hint: 'Min. 6 chars', ctrl: _pw, obscure: true)),
                  const SizedBox(width: 12),
                  Expanded(child: CInput(label: 'Confirm', hint: 'Confirm', ctrl: _pw2, obscure: true)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: GoldBtn(
                      text: 'SUBMIT',
                      full: true,
                      loading: auth.loading,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GoldBtn(
                      text: 'RESET',
                      outline: true,
                      full: true,
                      onPressed: _reset,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.read<AuthProvider>().clearError();
                      widget.onGoSignIn();
                    },
                    child: Text.rich(TextSpan(
                      text: 'Have an account? ',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.cream.withValues(alpha: 0.4),
                      ),
                      children: const [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
