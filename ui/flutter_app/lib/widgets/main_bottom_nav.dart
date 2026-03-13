import 'dart:ui';
import 'package:flutter/material.dart';

/// Floating pill-shaped bottom navigation bar with glassmorphic sliding bubble.
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, iconOut: Icons.home_outlined, label: 'Home'),
    _NavItem(icon: Icons.grid_view_rounded, iconOut: Icons.grid_view_outlined, label: 'Categories'),
    _NavItem(icon: Icons.notifications_rounded, iconOut: Icons.notifications_outlined, label: 'Notify'),
    _NavItem(icon: Icons.account_circle_rounded, iconOut: Icons.account_circle_outlined, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final pillColor = isDark
        ? scheme.surfaceContainerHigh.withOpacity(0.92)
        : const Color(0xFFF2F3F7).withOpacity(0.92);
    final selectedColor = scheme.onSurface;
    final unselectedColor = isDark
        ? Colors.white.withOpacity(0.40)
        : scheme.onSurfaceVariant.withOpacity(0.50);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / _items.length;
                  final bubbleW = itemWidth - 8;
                  const bubbleH = 56.0;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glassmorphic sliding bubble
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        left: selectedIndex * itemWidth + (itemWidth - bubbleW) / 2,
                        child: Container(
                          width: bubbleW,
                          height: bubbleH,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.10)
                                : scheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(bubbleH / 2),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.12)
                                  : scheme.primary.withOpacity(0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.white.withOpacity(0.04)
                                    : scheme.primary.withOpacity(0.08),
                                blurRadius: 12,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Items
                      Row(
                        children: List.generate(_items.length, (i) {
                          final item = _items[i];
                          final selected = selectedIndex == i;
                          final color = selected ? selectedColor : unselectedColor;

                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onDestinationSelected(i),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      selected ? item.icon : item.iconOut,
                                      key: ValueKey('${i}_$selected'),
                                      size: 26,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                    child: Text(
                                      item.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.iconOut,
    required this.label,
  });
  final IconData icon;
  final IconData iconOut;
  final String label;
}
