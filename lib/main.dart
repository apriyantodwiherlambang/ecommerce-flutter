import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/cart_page.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/whislist_page.dart';

import 'injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/main_page.dart';
import 'features/auth/presentation/pages/account_settings_page.dart';
import 'features/auth/presentation/pages/product_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    print('File .env berhasil dimuat');
    print('BASE_URL: ${dotenv.env['BASE_URL']}');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  di.initAuth();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Ecommerce App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/main': (context) => const MainPage(),
          '/account-settings': (context) => const AccountSettingsPage(),
          '/profile': (context) => const ProfilePage(),
          '/cart-page': (context) => CartScreen(), // ✅ diperbaiki di sini
          '/detail-product-page': (context) => ProductDetailPage(),
          '/whislist-page': (context) => WishlistPage(),
          '/forgot-password': (context) => ForgotPasswordPage(),
        },
      ),
    );
  }
}
