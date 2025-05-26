import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  var _previousUser;

  @override
  void initState() {
    super.initState();
    // Ambil data terbaru saat halaman dibuka
    context.read<AuthCubit>().fetchCurrentUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _fillControllers(user) {
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _addressController.text = user.address ?? '';
    _phoneController.text = user.phoneNumber ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedImage != null) {
      final file = File(pickedImage.path);
      context.read<AuthCubit>().setNewProfileImage(file);
    }
  }

  void _saveProfile(AuthCubit cubit) {
    cubit.updateUser(
      username: _usernameController.text,
      email: _emailController.text,
      password: null,
      address:
          _addressController.text.isNotEmpty ? _addressController.text : null,
      phoneNumber:
          _phoneController.text.isNotEmpty ? _phoneController.text : null,
      profileImageFile: cubit.newProfileImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (state.message.contains('Logout berhasil')) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (state.message.contains('Profil berhasil diperbarui')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil berhasil diperbarui')),
            );
            // Ambil data terbaru setelah update
            context.read<AuthCubit>().fetchCurrentUser();
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
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

          if (_previousUser != user) {
            _fillControllers(user);
            _previousUser = user;
          }

          final String baseUrl = dotenv.env['BASE_URL'] ?? '';
          final String? imagePath = user.profilePictureUrl;

          final String fullImageUrl = (imagePath != null &&
                  imagePath.isNotEmpty)
              ? '$baseUrl/$imagePath'
              : 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png';

          final newProfileImage = context.watch<AuthCubit>().newProfileImage;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    'Profil Admin',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: newProfileImage != null
                            ? FileImage(newProfileImage)
                            : NetworkImage(fullImageUrl) as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildEditableField(
                    label: 'Username',
                    controller: _usernameController,
                  ),
                  _buildEditableField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildEditableField(
                    label: 'Alamat',
                    controller: _addressController,
                  ),
                  _buildEditableField(
                    label: 'Nomor HP',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _saveProfile(context.read<AuthCubit>()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2972FE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
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
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 1, color: Color(0xFFBBBBBB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 2, color: Color(0xFF2972FE)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
