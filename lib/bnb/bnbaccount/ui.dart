import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String? username;
  final String? email;
  final String? profileImageUrl;
  final bool isLoading;
  final VoidCallback? onAvatarTap;

  const ProfileHeader({
    super.key,
    this.username,
    this.email,
    this.profileImageUrl,
    this.isLoading = false,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Image
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
              ),

              const SizedBox(height: 18),

              // Username
              isLoading
                  ? const SizedBox(
                      height: 24,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Text(
                      (username?.trim().isNotEmpty ?? false)
                          ? username!
                          : local.guestUser,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

              const SizedBox(height: 6),

              // Email
              Text(
                (email?.trim().isNotEmpty ?? false)
                    ? email!
                    : local.emailNotAvailable,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
