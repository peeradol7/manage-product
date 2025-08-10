import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/sku_master.dart';
import '../services/dio_service.dart';

class UpdateProductPage extends StatefulWidget {
  final SkuMasterDetail product;

  const UpdateProductPage({super.key, required this.product});

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _lengthController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  // State
  bool _isLoading = false;
  List<File> _newImages = [];
  List<int> _deletedImageIds = [];
  List<String> _currentImageUrls = [];

  // Image Picker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _currentImageUrls = List.from(widget.product.imageUrls);
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.product.skuName);
    _widthController = TextEditingController(
      text: widget.product.width?.toString() ?? '',
    );
    _lengthController = TextEditingController(
      text: widget.product.length?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.product.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.product.weight?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final totalCurrentImages = _currentImageUrls.length + _newImages.length;
      if (totalCurrentImages >= 7) {
        _showSnackBar('สามารถอัพโหลดได้สูงสุด 7 รูป', isError: true);
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        final maxAdditional = 7 - totalCurrentImages;
        final imagesToAdd = images.take(maxAdditional).toList();

        List<File> validImages = [];
        for (XFile xfile in imagesToAdd) {
          final file = File(xfile.path);
          final fileSizeInBytes = await file.length();
          final fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB

          if (fileSizeInMB > 10) {
            _showSnackBar('ไฟล์ ${xfile.name} มีขนาดเกิน 10 MB', isError: true);
            continue;
          }

          validImages.add(file);
        }

        if (validImages.isNotEmpty) {
          setState(() {
            _newImages.addAll(validImages);
          });

          if (images.length > maxAdditional) {
            _showSnackBar(
              'สามารถเพิ่มได้อีก $maxAdditional รูป (รวมได้สูงสุด 7 รูป)',
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาดในการเลือกรูป: $e', isError: true);
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeCurrentImage(int index) {
    // Since we don't have image IDs, we'll simulate by removing from display
    // In a real app, you'd need to track image IDs from the API
    setState(() {
      _currentImageUrls.removeAt(index);
      // Add a dummy ID for deletion (you'd need real image IDs from API)
      _deletedImageIds.add(index + 1); // This is just for demo
    });
  }

  Widget _buildNameSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'ชื่อสินค้า',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อสินค้า',
                border: OutlineInputBorder(),
                hintText: 'กรอกชื่อสินค้า',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกชื่อสินค้า';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'รูปภาพสินค้า',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: (_currentImageUrls.length + _newImages.length) < 7
                      ? _pickImages
                      : null,
                  icon: const Icon(Icons.add_photo_alternate),
                  tooltip: 'เพิ่มรูป',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Image limits info
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'สูงสุด 7 รูป | ขนาดไฟล์สูงสุด 10 MB | ปัจจุบัน: ${_currentImageUrls.length + _newImages.length}/7',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Current Images
            if (_currentImageUrls.isNotEmpty) ...[
              const Text(
                'รูปปัจจุบัน:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _currentImageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _currentImageUrls[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeCurrentImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (_newImages.isNotEmpty) ...[
              const Text(
                'รูปใหม่ที่เลือก:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newImages.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<int>(
                      future: _newImages[index].length(),
                      builder: (context, snapshot) {
                        final fileSizeInMB = snapshot.hasData
                            ? (snapshot.data! / (1024 * 1024)).toStringAsFixed(
                                1,
                              )
                            : '...';

                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _newImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeNewImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${fileSizeInMB} MB',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],

            // Add Image Button
            if (_currentImageUrls.isEmpty && _newImages.isEmpty)
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('เพิ่มรูปภาพ'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'สูงสุด 7 รูป | ไฟล์ละไม่เกิน 10 MB',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.straighten,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'ขนาดและน้ำหนัก',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration: const InputDecoration(
                      labelText: 'กว้าง (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lengthController,
                    decoration: const InputDecoration(
                      labelText: 'ยาว (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'สูง (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'น้ำหนัก (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = UpdateSkuMasterRequest(
        skuKey: widget.product.skuKey,
        skuName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        deleteImageIds: _deletedImageIds.isNotEmpty ? _deletedImageIds : null,
        width: _widthController.text.isNotEmpty
            ? double.tryParse(_widthController.text)
            : null,
        length: _lengthController.text.isNotEmpty
            ? double.tryParse(_lengthController.text)
            : null,
        height: _heightController.text.isNotEmpty
            ? double.tryParse(_heightController.text)
            : null,
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
      );

      final response = await _apiService.updateSkuMaster(
        request: request,
        newImages: _newImages.isNotEmpty ? _newImages : null,
      );

      if (response.success) {
        _showSnackBar('บันทึกข้อมูลเรียบร้อย');

        // Show warnings if any
        if (response.warnings.isNotEmpty) {
          for (String warning in response.warnings) {
            _showSnackBar('คำเตือน: $warning', isError: true);
          }
        }

        // Go back to previous page
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        _showSnackBar('เกิดข้อผิดพลาด: ${response.message}', isError: true);
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขสินค้า'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveChanges,
              child: const Text(
                'บันทึก',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildNameSection(),
              const SizedBox(height: 16),
              _buildImageSection(),
              const SizedBox(height: 16),
              _buildSizeSection(),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('กำลังบันทึก...'),
                          ],
                        )
                      : const Text(
                          'บันทึกการเปลี่ยนแปลง',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
