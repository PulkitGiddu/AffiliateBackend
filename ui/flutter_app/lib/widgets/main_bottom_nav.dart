import 'package:flutter/material.dart';

/// Persistent bottom nav (segmented style). Clearly visible in light and dark mode.
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<_NavSegment> segments = [
    _NavSegment(icon: Icons.home_rounded, iconOut: Icons.home_outlined, label: 'Home'),
    _NavSegment(icon: Icons.grid_view_rounded, iconOut: Icons.grid_view_outlined, label: 'Products'),
    _NavSegment(icon: Icons.card_giftcard_rounded, iconOut: Icons.card_giftcard_outlined, label: 'Coupons'),
    _NavSegment(icon: Icons.notifications_rounded, iconOut: Icons.notifications_outlined, label: 'Notify'),
    _NavSegment(icon: Icons.person_rounded, iconOut: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final secondary = scheme.secondary;
    // Bar: app theme gradient (matches app bar / header)
    final barGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [primary.withOpacity(0.4), secondary.withOpacity(0.2)]
          : [primary.withOpacity(0.15), secondary.withOpacity(0.25)],
    );
    final barBorder = isDark
        ? Colors.white.withOpacity(0.1)
        : primary.withOpacity(0.2);
    // Selected: pill with white/light fill, primary icon and text
    final pillBg = Colors.white.withOpacity(isDark ? 0.2 : 0.9);
    final selectedFg = primary;
    // Unselected: visible on gradient (white on dark, primary-tint on light)
    final unselectedFg = isDark
        ? Colors.white.withOpacity(0.85)
        : primary.withOpacity(0.85);

    return Container(
      decoration: BoxDecoration(
        gradient: barGradient,
        border: Border(top: BorderSide(color: barBorder, width: 1)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Row(
            children: List.generate(segments.length, (i) {
              final seg = segments[i];
              final selected = selectedIndex == i;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onDestinationSelected(i),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: selected ? pillBg : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              selected ? seg.icon : seg.iconOut,
                              size: 20,
                              color: selected ? selectedFg : unselectedFg,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            seg.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected ? selectedFg : unselectedFg,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavSegment {
  const _NavSegment({
    required this.icon,
    required this.iconOut,
    required this.label,
  });
  final IconData icon;
  final IconData iconOut;
  final String label;
}
