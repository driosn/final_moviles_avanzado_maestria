import 'dart:io';

import 'package:final_movil_aplicaciones_avanzado/core/injection/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/product.dart';
import '../bloc/products_bloc.dart';
import '../bloc/products_event.dart';
import '../bloc/products_state.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  File? _selectedImage;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Pinturas y Acabados',
    'Pisos y Revestimientos',
    'Iluminación',
    'Accesorios Decorativos',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price.toString();
    _categoryController.text = widget.product.category;
    _uploadedImageUrl = widget.product.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider.value(
        value: sl<ProductsBloc>(),
        child: BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) {
            if (state is ProductUpdated) {
              Navigator.of(context).pop();
            } else if (state is ProductsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Editar Producto', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // Imagen del producto
                  _buildImageSection(),
                  const SizedBox(height: 24),

                  // Nombre del producto
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                      prefixIcon: Icon(Icons.inventory),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre del producto';
                      }
                      if (value.length < 2) {
                        return 'El nombre debe tener al menos 2 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Precio del producto
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el precio del producto';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Por favor ingresa un precio válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Categoría del producto
                  DropdownButtonFormField<String>(
                    value: _categoryController.text,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoryController.text = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona una categoría';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón actualizar
                  BlocBuilder<ProductsBloc, ProductsState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is ProductsLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  if (_selectedImage != null) {
                                    _updateProductWithImage();
                                  } else if (_uploadedImageUrl != null) {
                                    _updateProduct();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Por favor selecciona una imagen para el producto'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: state is ProductsLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Actualizar Producto', style: TextStyle(fontSize: 16)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Imagen del Producto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Seleccionar Nueva Imagen'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
        ),
        const SizedBox(height: 8),
        if (_selectedImage != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          )
        else if (widget.product.imageUrl.isNotEmpty)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error, size: 50, color: Colors.red));
                },
              ),
            ),
          )
        else
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
              color: Colors.grey[100],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No hay imagen seleccionada', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al seleccionar imagen: $e'), backgroundColor: Colors.red));
    }
  }

  void _updateProductWithImage() {
    if (_selectedImage != null) {
      final product = Product(
        id: widget.product.id,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        category: _categoryController.text,
        imageUrl: '', // Se llenará con la URL de la imagen subida
        createdAt: widget.product.createdAt,
        updatedAt: DateTime.now(),
      );

      sl<ProductsBloc>().add(UpdateProductWithImage(product: product, imagePath: _selectedImage!.path));
    }
  }

  void _updateProduct() {
    final product = Product(
      id: widget.product.id,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      category: _categoryController.text,
      imageUrl: _uploadedImageUrl!,
      createdAt: widget.product.createdAt,
      updatedAt: DateTime.now(),
    );

    context.read<ProductsBloc>().add(UpdateProduct(product: product));
  }
}
