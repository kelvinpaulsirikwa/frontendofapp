import 'package:bnbfrontendflutter/bnb/bnbhome/favorite.dart';
import 'package:bnbfrontendflutter/bnb/reusablecomponent/hotelcards.dart';
import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/bnb/searching/homesearching.dart';
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

                          const SizedBox(height: 20),

                          // ------------------------
                          // REGION DROPDOWN
                          // ------------------------
                          GestureDetector(
                            onTap: onToggleDropdown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: softCream,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: deepTerracotta,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        displayRegion,
                                        style: const TextStyle(
                                          color: textDark,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AnimatedRotation(
                                    turns: isDropdownOpen ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          height: 55, // 👈 smaller and elegant
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
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

                              return GestureDetector(
                                onTap: () =>
                                    onTypeSelected(type['name'] as String),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? earthGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? earthGreen
                                          : Colors.grey.shade300,
                                      width: 1.2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    displayName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade800,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Only show "Near By" section when "All Types" is selected
                        if (selectedType == _allTypesValue) ...[
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidgets.iconTextRow(
                                icon: Icons.location_on,
                                text: local.homeNearByTitle,
                              ),
                              Text(
                                local.homeViewAll,
                                style: const TextStyle(
                                  color: deepTerracotta,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: deepTerracotta,
                              ),
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
          if (isDropdownOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: onToggleDropdown,
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
          if (isDropdownOpen)
            Builder(
              builder: (context) {
                // Calculate dropdown width to match button width
                // Button is now full width (minus horizontal padding)
                final screenWidth = MediaQuery.of(context).size.width;
                const horizontalPadding =
                    20.0; // left and right padding from parent
                final dropdownWidth = screenWidth - (horizontalPadding * 2);

                return Positioned(
                  top: MediaQuery.of(context).padding.top + 140,
                  left: horizontalPadding,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: dropdownWidth,
                      constraints: const BoxConstraints(maxHeight: 350),
                      decoration: BoxDecoration(
                        color: softCream,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: richBrown.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: regions.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedRegion == regions[index];
                          return GestureDetector(
                            onTap: () => onRegionSelected(regions[index]),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? earthGreen.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    regions[index] == _allRegionsValue
                                        ? local.homeAllRegions
                                        : regions[index],
                                    style: TextStyle(
                                      color: isSelected ? earthGreen : textDark,
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: earthGreen,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FixedHeaderDelegate({required this.child});

  @override
  double get minExtent => 200;

  @override
  double get maxExtent => 200;

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
