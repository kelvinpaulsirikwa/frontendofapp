import 'package:bnbfrontendflutter/bnb/bnbhome/favorite.dart';
import 'package:bnbfrontendflutter/layouts/hotelcards.dart';
import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/bnb/searching/homesearching.dart';
import 'package:bnbfrontendflutter/layouts/loading.dart';
import 'package:bnbfrontendflutter/utility/componet.dart';
import 'package:bnbfrontendflutter/utility/errorcontentretry.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:bnbfrontendflutter/utility/text.dart';
import 'package:bnbfrontendflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:bnbfrontendflutter/models/bnbmodel.dart';

class HomeLayout extends StatelessWidget {
  final String selectedRegion;
  final String selectedType;
  final bool isDropdownOpen;
  final List<String> regions;
  final List<Map<String, dynamic>> accommodationTypes;
  final List<SimpleMotel> featured;
  final List<SimpleMotel> popular;
  final bool hasMorePages;
  final bool isLoadingMore;
  final VoidCallback onToggleDropdown;
  final Function(String) onRegionSelected;
  final Function(String) onTypeSelected;
  final VoidCallback onRefresh;
  final VoidCallback? onLoadMore;

  static const String _allRegionsValue = 'All Regions';
  static const String _allTypesValue = 'All Types';
  static const String _unknownValue = 'Unknown';

  const HomeLayout({
    super.key,
    required this.selectedRegion,
    required this.selectedType,
    required this.isDropdownOpen,
    required this.regions,
    required this.accommodationTypes,
    required this.featured,
    required this.popular,
    this.hasMorePages = false,
    this.isLoadingMore = false,
    required this.onToggleDropdown,
    required this.onRegionSelected,
    required this.onTypeSelected,
    required this.onRefresh,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    final displayRegion = selectedRegion == _allRegionsValue
        ? local.homeAllRegions
        : selectedRegion;
    return Scaffold(
      backgroundColor: warmSand,
      extendBodyBehindAppBar: true,
      appBar: KivuliAppBar(),
      floatingActionButton: _RegionFab(
        displayRegion: displayRegion,
        onTap: () => _showRegionBottomSheet(
          context,
          regions: regions,
          selectedRegion: selectedRegion,
          allRegionsValue: _allRegionsValue,
          onRegionSelected: onRegionSelected,
          local: local,
        ),
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent &&
                  hasMorePages &&
                  !isLoadingMore &&
                  onLoadMore != null) {
                onLoadMore!();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FixedHeaderDelegate(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [deepTerracotta, richBrown],
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 20,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        children: [
                          // ------------------------
                          // FAVORITE - TITLE - SEARCH
                          // ------------------------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconContainer(
                                icon: Icons.favorite_border,
                                iconColor: softCream,
                                backgroundColor: Colors.white24,
                                iconSize: 22,
                                onTap: () {
                                  NavigationUtil.pushwithslideTo(
                                    context,
                                    const FavoritePage(),
                                  );
                                },
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      local.homeWelcomeTitle,
                                      style: const TextStyle(
                                        color: softCream,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      local.homeWelcomeSubtitle,
                                      style: const TextStyle(
                                        color: warmSand,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconContainer(
                                icon: Icons.search,
                                iconColor: softCream,
                                backgroundColor: Colors.white24,
                                iconSize: 22,
                                onTap: () {
                                  NavigationUtil.pushwithslideTo(
                                    context,
                                    const HomeSearching(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              color: deepTerracotta,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              local.homeAccommodationTypeTitle,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 32,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: accommodationTypes.length,
                            itemBuilder: (context, index) {
                              final type = accommodationTypes[index];
                              final name =
                                  (type['name'] as String?) ?? _unknownValue;
                              final displayName = name == _unknownValue
                                  ? local.homeUnknownType
                                  : name == _allTypesValue
                                      ? local.homeAllTypes
                                      : name;
                              final isSelected = selectedType == name;

                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () =>
                                      onTypeSelected(type['name'] as String),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? earthGreen
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? earthGreen
                                            : const Color(0xFFE5E7EB),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      displayName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
  if (selectedType == _allTypesValue) ...[
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidgets.iconTextRow(
                                icon: Icons.location_on,
                                text: local.homeNearByTitle,
                              ),
                              
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Only show "Near By" section when "All Types" is selected
                if (selectedType == _allTypesValue)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 285,
                      child: featured.isEmpty
                          ? ErrorContent(
                              message: local.homeNoDataTitle,
                              color: richBrown,
                              onRetry: onRefresh,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: featured.length,
                              itemBuilder: (context, index) {
                                final motel = featured[index];
                                return HotelCards.horizontalHotelCard(
                                  motel: motel,
                                  context: context,
                                );
                              },
                            ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: sunsetOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          local.homePopularDestinationsTitle,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (popular.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: ErrorContent(
                        message: local.homeNoDataTitle,
                        color: richBrown,
                        onRetry: onRefresh,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index < popular.length) {
                          final motel = popular[index];
                          return HotelCards.verticalHotelCard(
                            motel: motel,
                            context: context,
                          );
                        }

                        // Loading indicator at the bottom
                        if (isLoadingMore) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child:Loading.infiniteLoading(context),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      }, childCount: popular.length + (isLoadingMore ? 1 : 0)),
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

void _showRegionBottomSheet(
  BuildContext context, {
  required List<String> regions,
  required String selectedRegion,
  required String allRegionsValue,
  required Function(String) onRegionSelected,
  required AppLocalizations local,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _RegionBottomSheetContent(
      regions: regions,
      selectedRegion: selectedRegion,
      allRegionsValue: allRegionsValue,
      onRegionSelected: (region) {
        onRegionSelected(region);
        Navigator.pop(ctx);
      },
      local: local,
    ),
  );
}

class _RegionBottomSheetContent extends StatelessWidget {
  final List<String> regions;
  final String selectedRegion;
  final String allRegionsValue;
  final Function(String) onRegionSelected;
  final AppLocalizations local;

  const _RegionBottomSheetContent({
    required this.regions,
    required this.selectedRegion,
    required this.allRegionsValue,
    required this.onRegionSelected,
    required this.local,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: softCream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: richBrown.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: richBrown.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: deepTerracotta, size: 24),
                const SizedBox(width: 10),
                Text(
                  local.homeAllRegions,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: regions.length,
              itemBuilder: (context, index) {
                final isSelected = selectedRegion == regions[index];
                return GestureDetector(
                  onTap: () => onRegionSelected(regions[index]),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? earthGreen.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          regions[index] == allRegionsValue
                              ? local.homeAllRegions
                              : regions[index],
                          style: TextStyle(
                            color: isSelected ? earthGreen : textDark,
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: earthGreen,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionFab extends StatelessWidget {
  final String displayRegion;
  final VoidCallback onTap;

  const _RegionFab({
    required this.displayRegion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: deepTerracotta.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: richBrown.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [deepTerracotta, richBrown],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: softCream,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    displayRegion,
                    style: const TextStyle(
                      color: softCream,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: softCream,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FixedHeaderDelegate({required this.child});

  @override
  double get minExtent => 120;

  @override
  double get maxExtent => 120;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
