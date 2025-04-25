import 'package:flutter/material.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/home_page.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/whislist_page.dart';
import 'profile_page.dart';
import 'cart_page.dart';
import 'whislist_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CartScreen(),
    WishlistPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, 10), // turun 4 pixel
              child: Image.asset(
                'assets/home.png',
                height: 24,
                color: _currentIndex == 0 ? Colors.blue : Colors.grey,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, 10),
              child: Image.asset(
                'assets/cart.png',
                height: 24,
                color: _currentIndex == 1 ? Colors.blue : Colors.grey,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, 10),
              child: Image.asset(
                'assets/whislist.png',
                height: 24,
                color: _currentIndex == 2 ? Colors.blue : Colors.grey,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, 10),
              child: Image.asset(
                'assets/profile.png',
                height: 24,
                color: _currentIndex == 3 ? Colors.blue : Colors.grey,
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
