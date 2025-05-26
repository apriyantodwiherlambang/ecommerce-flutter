import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend_ecommerce/features/categories/data/models/category_model.dart';
import 'package:frontend_ecommerce/features/products/presentation/cubit/product_upload_cubit.dart';
import 'package:frontend_ecommerce/features/products/presentation/cubit/product_upload_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class AdminUploadProductPage extends StatefulWidget {
  const AdminUploadProductPage({super.key});

  @override
  State<AdminUploadProductPage> createState() => _AdminUploadProductPageState();
}

class _AdminUploadProductPageState extends State<AdminUploadProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  XFile? _image;
  bool _isLoadingCategories = true;

  final ImagePicker _picker = ImagePicker();
  final Dio _dio = GetIt.instance<Dio>();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          _categories = data.map((e) => CategoryModel.fromJson(e)).toList();
          _isLoadingCategories = false;
        });
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kategori: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _image = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori produk')),
      );
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar produk')),
      );
      return;
    }

    final cubit = context.read<ProductUploadCubit>();

    cubit.upload(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      categoryId: _selectedCategory!.id,
      imageFile: File(_image!.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Produk')),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : BlocConsumer<ProductUploadCubit, ProductUploadState>(
              listener: (context, state) {
                if (state is ProductUploadSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produk berhasil diupload')),
                  );
                  Navigator.pop(context);
                } else if (state is ProductUploadFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal upload: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                final isUploading = state is ProductUploadLoading;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const ClampingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Produk',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Masukkan nama'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Masukkan deskripsi'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Harga',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Masukkan harga';
                            final n = int.tryParse(v);
                            if (n == null || n <= 0)
                              return 'Harga harus lebih dari 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stok',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Masukkan stok';
                            final n = int.tryParse(v);
                            if (n == null || n < 0) return 'Stok tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<CategoryModel>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<CategoryModel>(
                              value: cat,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
                          validator: (val) =>
                              val == null ? 'Pilih kategori' : null,
                        ),
                        if (_selectedCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Kategori dipilih: ${_selectedCategory!.name}',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image),
                              label: const Text('Pilih Gambar'),
                            ),
                            const SizedBox(width: 12),
                            if (_image != null)
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Gambar dipilih',
                                        style: const TextStyle(
                                            color: Colors.green),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (_image == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Gambar wajib dipilih',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        if (_image != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_image!.path),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: AbsorbPointer(
                            absorbing: isUploading,
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: isUploading
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Mengupload...'),
                                      ],
                                    )
                                  : const Text('Upload Produk'),
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
}
