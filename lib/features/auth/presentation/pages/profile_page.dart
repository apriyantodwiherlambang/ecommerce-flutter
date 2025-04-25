import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (state.message.contains('Logout berhasil')) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (state.message.contains('Update berhasil')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil berhasil diperbarui')),
            );
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = context.read<AuthCubit>().currentUser;

            if (user == null) {
              return const Center(
                child: Text(
                  'Pengguna tidak ditemukan.\nSilakan login kembali.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          const AssetImage('assets/profile-user.png'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Field
                    _buildField('Nama Kamu', user.username),
                    _buildField('Alamat Email', user.email ?? ''),
                    // _buildField('Lokasi', user.location ?? 'Belum diatur'),
                    // _buildField('Nomor Handphone', user.phoneNumber ?? ''),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/account-settings');
                          // Fungsi update profile
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2972FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Ubah Profile',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => context.read<AuthCubit>().logout(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2972FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
