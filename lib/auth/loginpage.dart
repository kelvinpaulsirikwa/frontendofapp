import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:bnbfrontendflutter/l10n/languagemanagemen.dart';
import 'package:bnbfrontendflutter/services/google_auth_sign.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/utility/alert.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final GoogleSignInManager _signInManager = GoogleSignInManager();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Top bar with language selector
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLanguageSelector(local),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          _buildMinimalLogo(),

                          const SizedBox(height: 48),

                          // Title
                          Text(
                            local.loginTitle,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            local.loginSubtitle,
                            style: TextStyle(
                              fontSize: 15,
                              color: textDark.withOpacity(0.6),
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 64),

                          // Sign in button
                          _buildSignInButton(local),

                          const SizedBox(height: 24),

                          // Divider with text
                          _buildDivider(local),

                          const SizedBox(height: 24),

                          // Benefits
                          _buildBenefits(local),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Footer
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildFooter(local),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(AppLocalizations local) {
    return GestureDetector(
      onTap: () {
        LanguageBottomSheet.show(
          context,
          Localizations.localeOf(context).languageCode,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 16,
              color: textDark.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              local.language,
              style: TextStyle(
                fontSize: 13,
                color: textDark.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: deepTerracotta.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/logo/applogo.png',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.hotel_rounded,
              size: 40,
              color: deepTerracotta.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(AppLocalizations local) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          AlertReturn.showLoadingDialog(context);

          try {
            await _signInManager.signInWithGoogle(context);
            Navigator.of(context).pop();
          } catch (error) {
            Navigator.of(context).pop();
            AlertReturn.showerror(context, error.toString());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: textDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/google.png',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              local.loginContinueWithGoogle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(AppLocalizations local) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            local.loginWhyUsTitle,
            style: TextStyle(
              fontSize: 12,
              color: textDark.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildBenefits(AppLocalizations local) {
    return Column(
      children: [
        _buildBenefitItem(
          icon: Icons.bookmark_border,
          text: local.loginBenefitSaveFavorites,
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(
          icon: Icons.access_time,
          text: local.loginBenefitQuickBooking,
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(
          icon: Icons.notifications_none,
          text: local.loginBenefitExclusiveDeals,
        ),
      ],
    );
  }

  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: deepTerracotta.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: deepTerracotta),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: textDark.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AppLocalizations local) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 16),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: textDark.withOpacity(0.5),
                height: 1.5,
              ),
              children: [
                TextSpan(text: local.loginFooterPrefix),
                TextSpan(
                  text: local.loginFooterTerms,
                  style: TextStyle(
                    color: textDark.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: local.loginFooterAnd),
                TextSpan(
                  text: local.privacyPolicy,
                  style: TextStyle(
                    color: textDark.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
