import 'package:bnbfrontendflutter/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:geolocator/geolocator.dart';
import 'newrestmotel.dart';
import 'nearmemotel.dart';
import 'topsearchmotel.dart';

class DraggableBottomSheet extends StatefulWidget {
  final Function(String) onLocationSelected;
  final List<Map<String, dynamic>> motels;
  final Function(List<Map<String, dynamic>>, String)? onMotelsUpdated;
  final Function(String)? onTabChanged;
  final Function(double radius, Position? position)? onRadiusChanged;

  const DraggableBottomSheet({
    super.key,
    required this.onLocationSelected,
    this.motels = const [],
    this.onMotelsUpdated,
    this.onTabChanged,
    this.onRadiusChanged,
  });

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  int _currentTabIndex = 1; // Default to "Near Me" tab

  String _getTabType(int index) {
    switch (index) {
      case 0:
        return 'new';
      case 1:
        return 'near_me';
      case 2:
        return 'top';
      default:
        return 'near_me';
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    final tabType = _getTabType(index);
    if (widget.onTabChanged != null) {
      widget.onTabChanged!(tabType);
    }
    // Force a refresh by triggering a rebuild after a short delay
    // This ensures data is resent when tab becomes active
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _currentTabIndex == index) {
        // Trigger rebuild to ensure active tab resends data
        setState(() {});
      }
    });
  }

  void _onMotelsUpdated(List<Map<String, dynamic>> motels, String tabType) {
    if (widget.onMotelsUpdated != null) {
      widget.onMotelsUpdated!(motels, tabType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SlidingUpPanel(
      minHeight: screenHeight * 0.35, // Collapsed height: 35% of screen
      maxHeight: screenHeight * 0.75, // Expanded height: 85% of screen
      color: warmSand,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      boxShadow: [
        BoxShadow(
          color: richBrown.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, -8),
        ),
      ],
      panel: DefaultTabController(
        length: 3,
        initialIndex: _currentTabIndex, // Set "Near Me" as default tab
        child: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            tabController.addListener(() {
              if (!tabController.indexIsChanging) {
                _onTabChanged(tabController.index);
              }
            });
            return Column(
              children: [
                // Drag handle with better styling
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // TabBar with modern styling
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: deepTerracotta,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: deepTerracotta.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: textDark,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    labelPadding: EdgeInsets.zero,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [SizedBox(width: 4), Text("New")],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [SizedBox(width: 4), Text("Near Me")],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [SizedBox(width: 4), Text("Spotlight")],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // TabBar content
                Expanded(
                  child: TabBarView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: NewRestMotel(
                          onMotelsUpdated: (motels) =>
                              _onMotelsUpdated(motels, 'new'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: NearMeMotel(
                          onMotelsUpdated: (motels) =>
                              _onMotelsUpdated(motels, 'near_me'),
                          onRadiusChanged: (radius, position) {
                            if (widget.onRadiusChanged != null) {
                              widget.onRadiusChanged!(radius, position);
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TopSearchMotel(
                          onMotelsUpdated: (motels) =>
                              _onMotelsUpdated(motels, 'top'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
