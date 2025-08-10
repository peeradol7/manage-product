import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Image URLs list
  final List<TextEditingController> _imageControllers = [];
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _weightController.dispose();
    for (var controller in _imageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeForm() {
    if (widget.product != null) {
      final product = widget.product!;
      _nameController.text = product.productName;
      _priceController.text = product.price.toString();
      _discountController.text = product.discount.toString();
      _widthController.text = product.width.toString();
      _lengthController.text = product.length.toString();
      _weightController.text = product.weight.toString();
      _isActive = product.isActive;

      // Initialize image controllers
      for (int i = 0; i < product.imageUrl.length && i < 7; i++) {
        final controller = TextEditingController(text: product.imageUrl[i]);
        _imageControllers.add(controller);
      }
    }

    // Ensure at least one image controller
    if (_imageControllers.isEmpty) {
      _imageControllers.add(TextEditingController());
    }
  }

  void _addImageField() {
    if (_imageControllers.length < 7) {
      setState(() {
        _imageControllers.add(TextEditingController());
      });
    }
  }

  void _removeImageField(int index) {
    if (_imageControllers.length > 1) {
      setState(() {
        _imageControllers[index].dispose();
        _imageControllers.removeAt(index);
      });
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get non-empty image URLs
      final imageUrls = _imageControllers
          .map((controller) => controller.text.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (imageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเพิ่ม URL รูปภาพอย่างน้อย 1 รูป')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (widget.product == null) {
        // Add new product
        _productService.addProduct(
          imageUrl: imageUrls,
          productName: _nameController.text.trim(),
          price: double.parse(_priceController.text),
          discount: double.parse(_discountController.text),
          isActive: _isActive,
          width: double.parse(_widthController.text),
          length: double.parse(_lengthController.text),
          weight: double.parse(_weightController.text),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เพิ่มสินค้าเรียบร้อยแล้ว')),
        );
      } else {
        // Update existing product
        _productService.updateProduct(
          widget.product!.id,
          imageUrl: imageUrls,
          productName: _nameController.text.trim(),
          price: double.parse(_priceController.text),
          discount: double.parse(_discountController.text),
          isActive: _isActive,
          width: double.parse(_widthController.text),
          length: double.parse(_lengthController.text),
          weight: double.parse(_weightController.text),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปเดตสินค้าเรียบร้อยแล้ว')),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'เพิ่มสินค้าใหม่' : 'แก้ไขสินค้า'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _saveProduct, child: const Text('บันทึก')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อสินค้า *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณาระบุชื่อสินค้า';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price and Discount Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'ราคา (บาท) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาระบุราคา';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'ราคาต้องเป็นตัวเลขที่มากกว่า 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'ส่วนลด (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final discount = double.tryParse(value);
                          if (discount == null ||
                              discount < 0 ||
                              discount > 100) {
                            return 'ส่วนลดต้องอยู่ระหว่าง 0-100';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dimensions Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _widthController,
                      decoration: const InputDecoration(
                        labelText: 'ความกว้าง (ซม.) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาระบุความกว้าง';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'ต้องเป็นตัวเลขที่มากกว่า 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lengthController,
                      decoration: const InputDecoration(
                        labelText: 'ความยาว (ซม.) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาระบุความยาว';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'ต้องเป็นตัวเลขที่มากกว่า 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'น้ำหนัก (กก.) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณาระบุน้ำหนัก';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'ต้องเป็นตัวเลขที่มากกว่า 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Status
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                  ),
                  const Text('เปิดใช้งานสินค้า'),
                ],
              ),
              const SizedBox(height: 24),

              // Image URLs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'URL รูปภาพ (สูงสุด 7 รูป)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (_imageControllers.length < 7)
                    TextButton.icon(
                      onPressed: _addImageField,
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มรูป'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Image URL Fields
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _imageControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageControllers[index],
                            decoration: InputDecoration(
                              labelText: 'รูปภาพที่ ${index + 1}',
                              hintText: 'https://example.com/image.jpg',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final uri = Uri.tryParse(value);
                                if (uri == null || !uri.hasAbsolutePath) {
                                  return 'URL ไม่ถูกต้อง';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_imageControllers.length > 1)
                          IconButton(
                            onPressed: () => _removeImageField(index),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.product == null
                              ? 'เพิ่มสินค้า'
                              : 'อัปเดตสินค้า',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
