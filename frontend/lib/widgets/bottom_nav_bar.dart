import 'package:flutter/material.dart';
import 'package:pedidolocal/core/constants.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartItemCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          AppConstants.bottomNavBarHeight +
          MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppConstants.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              iconOutlined: Icons.home_outlined,
              label: 'Inicio',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.favorite_rounded,
              iconOutlined: Icons.favorite_outline_rounded,
              label: 'Favoritos',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.shopping_bag_rounded,
              iconOutlined: Icons.shopping_bag_outlined,
              label: 'Carrinho',
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
              badgeCount: cartItemCount,
            ),
            _NavItem(
              icon: Icons.person_rounded,
              iconOutlined: Icons.person_outline_rounded,
              label: 'Perfil',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppConstants.darkGreen : AppConstants.mutedInk;
    final displayIcon = isSelected ? icon : iconOutlined;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppConstants.mutedGreen,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: AppConstants.bottomNavBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(displayIcon, size: 24, color: color),
                  if (badgeCount > 0)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        decoration: BoxDecoration(
                          color: AppConstants.danger,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppConstants.white,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppConstants.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
