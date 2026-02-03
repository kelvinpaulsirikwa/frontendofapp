import 'package:bnbfrontendflutter/layouts/hotelcards.dart';
import 'package:bnbfrontendflutter/services/favorites_service.dart';
import 'package:bnbfrontendflutter/utility/appbar.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/l10n/app_localizations.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: warmSand,
      appBar: SingleMGAppBar(local.favoritePageTitle, context: context),
      body: ValueListenableBuilder(
        valueListenable: FavoritesService.listenable(),
        builder: (context, box, _) {
          final favorites = FavoritesService.getFavorites();

          if (favorites.isEmpty) {
            return const _FavoritesEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final motel = favorites[index];
              return HotelCards.verticalHotelCard(
                motel: motel,
                context: context,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
          );
        },
      ),
    );
  }
}

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState();

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: deepTerracotta.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            local.favoriteEmptyTitle,
            style: const TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            local.favoriteEmptyDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textLight.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
