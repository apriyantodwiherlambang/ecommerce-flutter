import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import untuk .env

import 'injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart'; // Halaman login
import 'features/auth/presentation/pages/register_page.dart'; // Halaman register

void main() async {
  // Memuat file .env sebelum aplikasi dijalankan
  try {
    await dotenv.load();
    print('File .env berhasil dimuat');
    print('BASE_URL: ${dotenv.env['BASE_URL']}');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  di.initAuth(); // Inisialisasi dependency injection dengan fungsi yang benar
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Menyediakan AuthCubit untuk aplikasi
        BlocProvider<AuthCubit>(
          create: (_) => di.sl<AuthCubit>(), // Menyediakan AuthCubit melalui DI
        ),
      ],
      child: MaterialApp(
        title: 'Ecommerce App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/', // Rute awal aplikasi
        routes: {
          '/': (context) => const LoginPage(), // Rute untuk halaman login
          '/register': (context) =>
              const RegisterPage(), // Rute untuk halaman register
        },
      ),
    );
  }
}
