import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/user_home_page.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/whislist_page.dart';
import 'package:frontend_ecommerce/features/products/presentation/cubit/product_cubit.dart';
import 'package:frontend_ecommerce/injection_container.dart' as di;

import 'profile_page.dart';
import 'cart_page.dart';
import 'package:frontend_ecommerce/features/cart/cart_cubit.dart'; // Pastikan ini diimpor

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // List of widgets to display for each tab.
  // We initialize these once to avoid unnecessary widget recreation.
  final List<Widget> _pages = [
    BlocProvider<ProductCubit>(
      create: (_) => di.sl<ProductCubit>()..fetchProducts(),
      child: const UserHomePage(),
    ),
    // CartScreen does not need BlocProvider.value here as it's provided globally in main.dart's MultiBlocProvider.
    CartScreen(),
    WishlistPage(),
    const ProfilePage(),
  ];

  // This method handles tab selection and triggers cart data refresh when the cart tab is opened.
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // IMPORTANT: Trigger fetchCart() when the cart tab (index 1) is selected.
    // This ensures the cart data is always up-to-date for the currently logged-in user.
    if (index == 1) {
      context.read<CartCubit>().fetchCart();
      print(
          'MainPage: fetchCart() triggered on Cart tab selection.'); // Debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page from the list
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped, // Use the custom tab tap handler
        items: [
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, 4),
              child: Image.asset(
                'assets/home.png',
                height: 24,
                color: _currentIndex == 0 ? Colors.blue : Colors.grey,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, 4),
              child: Image.asset(
                'assets/cart.png',
                height: 24,
                color: _currentIndex == 1 ? Colors.blue : Colors.grey,
              ),
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, 4),
              child: Image.asset(
                'assets/whislist.png',
                height: 24,
                color: _currentIndex == 2 ? Colors.blue : Colors.grey,
              ),
            ),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, 4),
              child: Image.asset(
                'assets/profile.png',
                height: 24,
                color: _currentIndex == 3 ? Colors.blue : Colors.grey,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
