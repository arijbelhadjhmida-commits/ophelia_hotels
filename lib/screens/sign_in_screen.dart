import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../widgets/common.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onGoSignUp;
  final VoidCallback? onAdminSuccess;

  const SignInScreen({
    super.key,
    required this.onSuccess,
    required this.onGoSignUp,
    this.onAdminSuccess,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _cin = TextEditingController();
  final _pw = TextEditingController();

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (_cin.text.isEmpty || _pw.text.isEmpty) {
      return;
    }
    final ok = await auth.signIn(_cin.text, _pw.text);
    if (!mounted) return;
    if (ok) {
      if (auth.isAdmin && widget.onAdminSuccess != null) {
        widget.onAdminSuccess!();
      } else {
        widget.onSuccess();
      }
    }
  }

  @override
  void dispose() {
    _cin.dispose();
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue]),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
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
                  text: 'Welcome ',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    color: AppColors.cream,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Back',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 4),
                Text(
                  'Sign in to your account',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.cream.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 24),
                if (auth.error != null) ErrorBanner(message: auth.error!),
                CInput(label: 'CIN', hint: 'Your CIN (or "admin")', ctrl: _cin),
                CInput(label: 'Password', hint: 'Enter password', ctrl: _pw, obscure: true),
                const SizedBox(height: 8),
                GoldBtn(
                  text: 'SIGN IN',
                  full: true,
                  loading: auth.loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      auth.clearError();
                      widget.onGoSignUp();
                    },
                    child: Text.rich(TextSpan(
                      text: 'No account? ',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.cream.withValues(alpha: 0.4),
                      ),
                      children: const [
                        TextSpan(
                          text: 'Sign Up',
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
