import 'package:bnbfrontendflutter/bnb/bnbhome/favorite.dart';
import 'package:bnbfrontendflutter/bnb/reusablecomponent/layout.dart';
import 'package:bnbfrontendflutter/bnb/searching/homesearching.dart';
import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:bnbfrontendflutter/utility/navigateutility.dart';
import 'package:flutter/material.dart';

class SingleMGAppBar extends AppBar {
  SingleMGAppBar({
    super.key,
    required BuildContext context,
    required VoidCallback onToggleDropdown,
    required bool isDropdownOpen,
    required String displayRegion,
    required String title,
    required String subtitle,
  }) : super(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 170,
          flexibleSpace: Container(
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
              bottom: 0,
            ),
            child: Column(
              children: [
                // ------------------------------------
                // Row Icons + Title
                // ------------------------------------
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
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: softCream,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: warmSand,
                              fontSize: 14,
                              height: 1.4,
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

                // ------------------------------------
                // DROPDOWN REGION SELECTOR
                // ------------------------------------
                GestureDetector(
                  onTap: onToggleDropdown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: softCream,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: deepTerracotta,
                              size: 24,
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
                            size: 26,
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


class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FixedHeaderDelegate({required this.child});

  @override
  double get minExtent => 180;

  @override
  double get maxExtent => 180;

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
