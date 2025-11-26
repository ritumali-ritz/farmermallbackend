import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/primary_button.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _quantity = TextEditingController();
  final _desc = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _imageUrl;
  bool loading = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _quantity.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        // Upload image
        setState(() => loading = true);
        final uploadRes = await ApiService.uploadImage(image.path);
        setState(() => loading = false);

        if (uploadRes['statusCode'] == 200 && uploadRes['body'] is Map) {
          final body = uploadRes['body'] as Map;
          setState(() {
            _imageUrl = body['imageUrl']?.toString();
          });
          _showMessage('Image uploaded');
        } else {
          _showMessage('Failed to upload image');
        }
      }
    } catch (e) {
      setState(() => loading = false);
      _showMessage('Error picking image: $e');
    }
  }

  Future<void> addProduct() async {
    final name = _name.text.trim();
    final price = double.tryParse(_price.text);
    final qty = int.tryParse(_quantity.text);

    if (name.isEmpty || price == null || qty == null) {
      _showMessage('Name, price and quantity are required');
      return;
    }

    setState(() => loading = true);

    // Upload image if selected but not uploaded yet
    if (_selectedImage != null && _imageUrl == null) {
      try {
        final uploadRes = await ApiService.uploadImage(_selectedImage!.path);
        if (uploadRes['statusCode'] == 200 && uploadRes['body'] is Map) {
          _imageUrl = uploadRes['body']['imageUrl']?.toString();
        } else {
          if (!mounted) return;
          setState(() => loading = false);
          _showMessage('Failed to upload image. Please try again.');
          return;
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => loading = false);
        _showMessage('Error uploading image: $e');
        return;
      }
    }

    final user = await StorageService.getMap('current_user');
    final farmerId = user?['id'] ?? 1; // Fallback to 1 for demo
    final res = await ApiService.post('/farmer/addProduct', {
      'farmer_id': farmerId,
      'name': name,
      'price': price,
      'quantity': qty,
      'description': _desc.text.trim(),
      'image_url': _imageUrl,
    });

    if (!mounted) return;
    setState(() => loading = false);
    final code = res['statusCode'];
    final body = res['body'];
    if (code == 201 || code == 200) {
      _showMessage('Product added');
      Navigator.pop(context, true);
    } else {
      final msg = (body is Map && body['message'] != null)
          ? '${body['message']}'
          : "Failed";
      _showMessage(msg);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FDF4),
              Color(0xFFECFDF5),
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              title: const Text('Add Product'),
              backgroundColor: Colors.transparent),
          body: Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListView(
              children: [
                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 50, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text('Tap to add product image',
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Price (₹)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quantity,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Add Product',
                  onPressed: () => addProduct(),
                  loading: loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
