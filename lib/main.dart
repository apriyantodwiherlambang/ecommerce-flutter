import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_ecommerce/features/auth/presentation/pages/user_home_page.dart';
import 'package:frontend_ecommerce/features/cart/cart_cubit.dart';
import 'package:frontend_ecommerce/features/cart/cart_remote_datasource.dart';
import 'package:frontend_ecommerce/features/products/presentation/pages/admin_upload_product_page.dart';

import 'injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/products/presentation/cubit/product_upload_cubit.dart';
import 'features/categories/presentation/cubit/category_cubit.dart';

// Pages
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/main_page.dart';
import 'features/auth/presentation/pages/account_settings_page.dart';
import 'features/auth/presentation/pages/product_detail_page.dart';
import 'features/auth/presentation/pages/cart_page.dart';
import 'features/auth/presentation/pages/whislist_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/admin/presentation/pages/bottom-bar-admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print('File .env berhasil dimuat');
    print('BASE_URL: ${dotenv.env['BASE_URL']}');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  await di.initDependencies();
  print(
      'ProductCubit registered after initDependencies: ${di.sl.isRegistered<ProductCubit>()}');
  print(
      'ProductCubit registered before runApp: ${di.sl.isRegistered<ProductCubit>()}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()),
        // BlocProvider<ProductCubit>(
        //   create: (context) => di.sl<ProductCubit>()..fetchProducts(),
        //   child: const UserHomePage(),
        // ),
        // BlocProvider(create: (_) => di.sl<ProductCubit>()),
        BlocProvider(create: (_) => di.sl<ProductCubit>()..fetchProducts()),
        BlocProvider(create: (_) => di.sl<CategoryCubit>()),
        BlocProvider(create: (_) => di.sl<ProductUploadCubit>()),
        BlocProvider(
          create: (_) => di.sl<CartCubit>()..fetchCart(),
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
          '/main': (_) => const MainPage(),
          '/user-home': (_) => BlocProvider<ProductCubit>(
                create: (_) => di.sl<ProductCubit>(),
                child: const UserHomePage(),
              ),
          '/admin-dashboard': (_) => const AdminDashboardPage(),
          '/account-settings': (context) => const AccountSettingsPage(),
          '/profile': (context) => const ProfilePage(),
          '/cart-page': (context) => BlocProvider.value(
                value: di.sl<CartCubit>(),
                child: CartScreen(),
              ),

          '/detail-product-page': (context) {
            final product = ModalRoute.of(context)!.settings.arguments;
            return ProductDetailPage(product: product);
          },
          '/whislist-page': (context) => WishlistPage(),
          '/forgot-password': (context) => const ForgotPasswordPage(),
          '/admin-upload-product': (_) =>
              const AdminUploadProductPage(), // <- Tambahkan halaman ini
        },
      ),
    );
  }
}
