import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isSupplier;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.isSupplier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_shipping_outlined),
          label: isSupplier ? 'Loads' : 'Feed',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chats',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

void handleBottomNavTap(
  BuildContext context,
  bool isSupplier,
  int index,
) {
  switch (index) {
    case 0:
      context.go('/home');
      break;
    case 1:
      context.go(isSupplier ? '/supplier-dashboard' : '/trucker-feed');
      break;
    case 2:
      context.go('/chats');
      break;
    case 3:
      context.go('/profile');
      break;
  }
}
