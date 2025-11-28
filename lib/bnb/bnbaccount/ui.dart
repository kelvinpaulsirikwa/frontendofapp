import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                child: Center(
                  child: profileImageUrl != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: profileImageUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 120,
                              height: 120,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 120, // Diameter = radius * 2
                                height: 120,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4, // Optional: adjust thickness
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => CircleAvatar(
                              radius: 60,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                username?.isNotEmpty ?? false
                                    ? username![0].toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  fontSize: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            username?.isNotEmpty ?? false
                                ? username![0].toUpperCase()
                                : '',
                            style: const TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
