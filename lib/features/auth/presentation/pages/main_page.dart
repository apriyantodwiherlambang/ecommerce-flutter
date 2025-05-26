import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/user_home_page.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/whislist_page.dart';
import 'package:frontend_ecommerce/features/products/presentation/cubit/product_upload_cubit.dart'
    as Upload;
import 'package:frontend_ecommerce/features/products/presentation/cubit/product_cubit.dart';
import 'package:frontend_ecommerce/injection_container.dart' as di;

import 'profile_page.dart';
import 'cart_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return BlocProvider<ProductCubit>(
          create: (_) => di.sl<ProductCubit>()..fetchProducts(),
          child: const UserHomePage(),
        );
      case 1:
        return CartScreen();
      case 2:
        return WishlistPage();
      case 3:
        return const ProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_currentIndex),
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
