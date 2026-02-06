import 'package:bnbfrontendflutter/bnb/bnbaccount/aboutbnb.dart';
import 'package:bnbfrontendflutter/bnb/bnbaccount/currentstays.dart';
import 'package:bnbfrontendflutter/bnb/bnbaccount/paststays.dart';
import 'package:bnbfrontendflutter/bnb/bnbaccount/tac.dart';
import 'package:bnbfrontendflutter/bnb/bnbaccount/transcation.dart';
import 'package:bnbfrontendflutter/bnb/bnbaccount/ui.dart';
import 'package:bnbfrontendflutter/bnb/bnbaccount/upcomingbooking.dart';
import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:bnbfrontendflutter/l10n/languagemanagemen.dart';
import 'package:bnbfrontendflutter/utility/componet.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:bnbfrontendflutter/utility/text.dart';
import 'package:bnbfrontendflutter/services/google_auth_sign.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/sharedpreferences.dart';
import 'package:bnbfrontendflutter/bnb/bnbhome/favorite.dart';
import 'package:bnbfrontendflutter/services/favorites_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAccount extends StatefulWidget {
  const ProfileAccount({super.key});

  @override
  State<ProfileAccount> createState() => _ProfileAccountState();
}

class _ProfileAccountState extends State<ProfileAccount> {
  final GoogleSignInManager _googleSignInManager = GoogleSignInManager();

  String? _username;
  String? _email;
  String? _profileImageUrl;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final username = await UserPreferences.getUsername();
    final email = await UserPreferences.getEmail();
    final imageUrl = await UserPreferences.getGoogleImage();

    if (!mounted) return;

    setState(() {
      _username = username;
      _email = email;
      _profileImageUrl = imageUrl;
      _isLoadingUserData = false;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final local = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: softCream,
          title: Text(
            local.logOut,
            style: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            local.logoutConfirmation,
            style: const TextStyle(color: textDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                local.cancelAction,
                style: const TextStyle(color: textDark),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                local.logOut,
                style: const TextStyle(
                  color: sunsetOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: earthGreen)),
      );

      // Perform logout (this navigates to LoginPage and removes all routes,
      // so we don't need to pop the dialog - it will be removed automatically)
      await _googleSignInManager.signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: warmSand,
      appBar: KivuliAppBar(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Profile Card
            ProfileHeader(
              username: _username,
              email: _email,
              profileImageUrl: _profileImageUrl,
              isLoading: _isLoadingUserData,
              onAvatarTap: () {
                // open profile edit page or image picker
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidgets.iconTextRow(
                      icon: Icons.local_activity_outlined,
                      text: local.myActivityTitle,
                    ),
                    const SizedBox(height: 10),

                    _buildActivityCard(
                      icon: Icons.calendar_month,
                      title: local.currentStaysTitle,
                      subtitle: local.currentStaysSubtitle,
                      color: earthGreen,
                      onTap: () {
                        NavigationUtil.pushwithslideTo(context, const CurrentStays());
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildActivityCard(
                      icon: Icons.calendar_month_outlined,
                      title: local.upcomingBookingsTitle,
                      subtitle: local.upcomingBookingsSubtitle,
                      color: sunsetOrange,
                      onTap: () {
                        NavigationUtil.pushwithslideTo(
                          context,
                          const UpcomingBooking(),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildActivityCard(
                      icon: Icons.history_outlined,
                      title: local.pastStaysTitle,
                      subtitle: local.pastStaysSubtitle,
                      color: deepTerracotta,
                      onTap: () {
                        NavigationUtil.pushwithslideTo(context, const PastStays());
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildActivityCard(
                      icon: Icons.payment,
                      title: local.paymentHistoryTitle,
                      subtitle: local.paymentHistorySubtitle,
                      color: sunsetOrange,
                      onTap: () {
                        NavigationUtil.pushwithslideTo(
                          context,
                          const TranscationDetails(),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder(
                      valueListenable: FavoritesService.listenable(),
                      builder: (context, box, _) {
                        final count = FavoritesService.getFavorites().length;
                        final subtitle = local.favoritePlacesCount(count);
                        return _buildActivityCard(
                          icon: Icons.favorite,
                          title: local.favoritePlacesTitle,
                          subtitle: subtitle,
                          color: sunsetOrange,
                          onTap: () {
                            NavigationUtil.pushwithslideTo(
                              context,
                              const FavoritePage(),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    TextWidgets.iconTextRow(
                      icon: Icons.settings_outlined,
                      text: local.settingsTitle,
                    ),
                    const SizedBox(height: 10),
                    _buildActivityCard(
                      icon: Icons.language,
                      title: local.languageTitle,
                      subtitle: local.languageSubtitle,
                      color: sunsetOrange,
                      onTap: () {
                        LanguageBottomSheet.show(
                          context,
                          Localizations.localeOf(context).languageCode,
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidgets.iconTextRow(
                      icon: Icons.help_outline,
                      text: local.supportAboutTitle,
                    ),
                    const SizedBox(height: 10),
                    _buildActivityCard(
                      icon: Icons.info_outlined,
                      title: local.aboutBnBTitle,
                      subtitle: local.aboutBnBSubtitle,
                      color: sunsetOrange,
                      onTap: () {
                        NavigationUtil.pushwithslideTo(context, const AboutBnB());
                      },
                    ),
                    const SizedBox(height: 10),

                    _buildActivityCard(
                      icon: Icons.description_outlined,
                      title: local.termsOfService,
                      subtitle: local.termsOfServiceSubtitle,
                      color: sunsetOrange,
                      onTap: () {
                        NavigationUtil.pushwithslideTo(context, const TermsAndCondition());
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Logout Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _handleLogout(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout,
                              color: sunsetOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              local.logOut,
                              style: const TextStyle(
                                color: sunsetOrange,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      local.versionLabel('1.0.0'),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
