import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../data/api_service.dart';
import '../../../../core/secure_storage.dart';
import './profile_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().currentUser;
    if (user != null) {
      _usernameController = TextEditingController(text: user.username);
      _emailController = TextEditingController(text: user.email);
    } else {
      _usernameController = TextEditingController();
      _emailController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess &&
                state.message.contains('Update berhasil')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil berhasil diperbarui')),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Custom AppBar UI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(
                                120, 0), // Menggeser teks sedikit ke kiri
                            child: const Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Profile Picture
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(
                        user?.profilePictureUrl ??
                            'https://via.placeholder.com/150',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.username ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Fields with Editable Fields
                    _buildEditableField('Nama Kamu', _usernameController),
                    _buildEditableField('Alamat Email', _emailController),
                    _buildEditableField('Password Baru', _passwordController,
                        isPassword: true),

                    const SizedBox(height: 24),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final currentUser =
                                context.read<AuthCubit>().currentUser;
                            if (currentUser != null) {
                              final jwt = await getJwt();

                              if (jwt != null) {
                                await ApiService('http://192.168.130.38:3000')
                                    .updateUser(
                                  currentUser.id,
                                  _usernameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Perubahan berhasil disimpan')),
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfilePage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'JWT tidak ditemukan. Silakan login kembali.')),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2972FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
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

  // Build editable field for profile form
  Widget _buildEditableField(String label, TextEditingController controller,
      {bool isPassword = false}) {
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
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Wajib diisi' : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
