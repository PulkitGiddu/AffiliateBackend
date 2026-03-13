import 'package:flutter/material.dart';

class CategoryMeta {
  const CategoryMeta(this.icon, this.bgColor, this.iconColor);
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
}

CategoryMeta categoryMetaFor(String name, String slug) {
  final s = (slug.isEmpty ? name.toLowerCase() : slug).replaceAll(' ', '-');

  if (s.contains('all') || s.contains('for-you'))
    return const CategoryMeta(Icons.apps_rounded, Color(0xFFFFE0E0), Color(0xFFD32F2F));
  if (s.contains('electron') || s.contains('device'))
    return const CategoryMeta(Icons.devices_rounded, Color(0xFFE3F2FD), Color(0xFF1565C0));
  if (s.contains('men') && !s.contains('women'))
    return const CategoryMeta(Icons.checkroom_rounded, Color(0xFFFCE4EC), Color(0xFFC62828));
  if (s.contains('women'))
    return const CategoryMeta(Icons.dry_cleaning_rounded, Color(0xFFFFF3E0), Color(0xFFE65100));
  if (s.contains('watch') || s.contains('accessor'))
    return const CategoryMeta(Icons.watch_rounded, Color(0xFFE8EAF6), Color(0xFF283593));
  if (s.contains('home') || s.contains('lifestyle') || s.contains('kitchen'))
    return const CategoryMeta(Icons.weekend_rounded, Color(0xFFE8F5E9), Color(0xFF2E7D32));
  if (s.contains('health') || s.contains('beauty') || s.contains('hygiene'))
    return const CategoryMeta(Icons.spa_rounded, Color(0xFFF3E5F5), Color(0xFF7B1FA2));
  if (s.contains('book') || s.contains('music') || s.contains('station'))
    return const CategoryMeta(Icons.auto_stories_rounded, Color(0xFFE0F7FA), Color(0xFF00838F));
  if (s.contains('gift') || s.contains('cake'))
    return const CategoryMeta(Icons.card_giftcard_rounded, Color(0xFFFFF8E1), Color(0xFFFF8F00));
  if (s.contains('grocer') || s.contains('suppli'))
    return const CategoryMeta(Icons.local_grocery_store_rounded, Color(0xFFF1F8E9), Color(0xFF558B2F));
  if (s.contains('sport') || s.contains('fitness'))
    return const CategoryMeta(Icons.fitness_center_rounded, Color(0xFFE0F2F1), Color(0xFF00695C));
  if (s.contains('mobile') || s.contains('phone'))
    return const CategoryMeta(Icons.smartphone_rounded, Color(0xFFEDE7F6), Color(0xFF4527A0));
  if (s.contains('fashion') || s.contains('cloth'))
    return const CategoryMeta(Icons.checkroom_rounded, Color(0xFFFCE4EC), Color(0xFFC62828));
  if (s.contains('auto') || s.contains('vehicle'))
    return const CategoryMeta(Icons.directions_car_rounded, Color(0xFFE3F2FD), Color(0xFF1565C0));
  if (s.contains('furniture'))
    return const CategoryMeta(Icons.chair_rounded, Color(0xFFFFF3E0), Color(0xFFBF360C));
  if (s.contains('deal'))
    return const CategoryMeta(Icons.local_offer_rounded, Color(0xFFFFEBEE), Color(0xFFD32F2F));
  if (s.contains('appliance'))
    return const CategoryMeta(Icons.kitchen_rounded, Color(0xFFE0F2F1), Color(0xFF00695C));
  if (s.contains('toy') || s.contains('baby'))
    return const CategoryMeta(Icons.child_care_rounded, Color(0xFFFFF8E1), Color(0xFFFF8F00));

  return const CategoryMeta(Icons.category_rounded, Color(0xFFE8EAF6), Color(0xFF3949AB));
}

/// Circular category icon with colored background + label underneath.
class CategoryCircle extends StatelessWidget {
  const CategoryCircle({
    super.key,
    required this.label,
    required this.meta,
    required this.onTap,
    this.isSelected = false,
    this.size = 52,
    this.iconSize = 24,
    this.labelMaxLines = 2,
  });

  final String label;
  final CategoryMeta meta;
  final VoidCallback onTap;
  final bool isSelected;
  final double size;
  final double iconSize;
  final int labelMaxLines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final bg = isDark ? meta.iconColor.withOpacity(0.18) : meta.bgColor;
    final fg = isDark ? meta.iconColor.withOpacity(0.9) : meta.iconColor;
    final textColor = isSelected ? scheme.primary : scheme.onSurface;

    final borderColor = isSelected
        ? scheme.primary
        : isDark
            ? meta.iconColor.withOpacity(0.12)
            : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size + 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bg,
                border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                boxShadow: isSelected
                    ? [BoxShadow(color: scheme.primary.withOpacity(0.2), blurRadius: 8)]
                    : null,
              ),
              child: Icon(meta.icon, size: iconSize, color: fg),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
                height: 1.2,
              ),
              maxLines: labelMaxLines,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
