import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend_ecommerce/features/products/presentation/cubit/product_upload_cubit.dart'
    as upload_cubit;
import 'package:frontend_ecommerce/features/products/presentation/cubit/product_cubit.dart'
    as product_cubit;
import 'package:frontend_ecommerce/features/products/product_injection.dart';

import 'admin_home_page.dart';
import 'admin_profile_page.dart';
import 'package:frontend_ecommerce/features/products/presentation/pages/admin_upload_product_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      AdminHomePage(),
      AdminUploadProductPage(),
      AdminProfilePage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<upload_cubit.ProductUploadCubit>(
          create: (_) => sl<upload_cubit.ProductUploadCubit>(),
        ),
        BlocProvider<product_cubit.ProductCubit>(
          create: (_) => sl<product_cubit.ProductCubit>(),
        ),
      ],
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Transform.translate(
                offset: const Offset(0, 10),
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
                child: Icon(
                  Icons.add_circle,
                  size: 32,
                  color: _currentIndex == 1 ? Colors.blue : Colors.grey,
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
                  color: _currentIndex == 2 ? Colors.blue : Colors.grey,
                ),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
