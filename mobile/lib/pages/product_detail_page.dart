import 'package:flutter/material.dart';

import '../models/sku_master.dart';
import '../services/dio_service.dart';
import 'update_product_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int skuKey;

  const ProductDetailPage({super.key, required this.skuKey});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController();

  SkuMasterDetail? _product;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load product detail once when page opens
    _loadProductDetail(forceRefresh: false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final product = await _apiService.getSkuMasterDetail(
        widget.skuKey,
        forceRefresh: forceRefresh,
      );

      // Update UI with new data
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Widget _buildImageGallery() {
    if (_product?.imageUrls.isEmpty ?? true) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'ไม่มีรูปภาพ',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Main Image
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: _product!.imageUrls.length,
              itemBuilder: (context, index) {
                // Add cache busting parameter to image URL
                final imageUrl = _product!.imageUrls[index];
                final cacheBustedUrl = imageUrl.contains('?')
                    ? '$imageUrl&_t=${DateTime.now().millisecondsSinceEpoch}'
                    : '$imageUrl?_t=${DateTime.now().millisecondsSinceEpoch}';

                return Image.network(
                  cacheBustedUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                );
              },
            ),
          ),
        ),

        // Image Indicators
        if (_product!.imageUrls.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _product!.imageUrls.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                ),
              ),
            ),
          ),

          // Image Counter
          const SizedBox(height: 8),
          Text(
            '${_currentImageIndex + 1} จาก ${_product!.imageUrls.length}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildProductInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            Text(
              _product!.skuName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Product Key
            Row(
              children: [
                Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'รหัสสินค้า: ${_product!.skuKey}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeDetails() {
    print('=== _buildSizeDetails START ===');
    print('_product is null: ${_product == null}');
    if (_product != null) {
      print('_product details:');
      print('  - SkuName: ${_product!.skuName}');
      print(
        '  - Width: ${_product!.width} (type: ${_product!.width.runtimeType})',
      );
      print(
        '  - Length: ${_product!.length} (type: ${_product!.length.runtimeType})',
      );
      print(
        '  - Height: ${_product!.height} (type: ${_product!.height.runtimeType})',
      );
      print(
        '  - Weight: ${_product!.weight} (type: ${_product!.weight.runtimeType})',
      );
    }

    // Force rebuild when product data changes
    final hasSize =
        _product?.width != null ||
        _product?.length != null ||
        _product?.height != null ||
        _product?.weight != null;

    print('hasSize calculation:');
    print('  - width != null: ${_product?.width != null}');
    print('  - length != null: ${_product?.length != null}');
    print('  - height != null: ${_product?.height != null}');
    print('  - weight != null: ${_product?.weight != null}');
    print('  - hasSize result: $hasSize');

    if (!hasSize) {
      print('Returning "no size data" card');
      print('=== _buildSizeDetails END (no size) ===');
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
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
              const SizedBox(height: 12),
              Text(
                'ยังไม่มีข้อมูลขนาด',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    print('Returning "has size data" card');
    print('Building size items:');
    print(
      '  - width item: ${_product?.width != null ? "YES (${_product!.width})" : "NO"}',
    );
    print(
      '  - length item: ${_product?.length != null ? "YES (${_product!.length})" : "NO"}',
    );
    print(
      '  - height item: ${_product?.height != null ? "YES (${_product!.height})" : "NO"}',
    );
    print(
      '  - weight item: ${_product?.weight != null ? "YES (${_product!.weight})" : "NO"}',
    );
    print('=== _buildSizeDetails END (has size) ===');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                if (_product?.width != null)
                  _buildSizeItem(
                    'กว้าง',
                    _product!.width!,
                    'cm',
                    Icons.width_normal,
                  ),
                if (_product?.length != null)
                  _buildSizeItem('ยาว', _product!.length!, 'cm', Icons.height),
                if (_product?.height != null)
                  _buildSizeItem(
                    'สูง',
                    _product!.height!,
                    'cm',
                    Icons.vertical_align_top,
                  ),
                if (_product?.weight != null)
                  _buildSizeItem(
                    'น้ำหนัก',
                    _product!.weight!,
                    'kg',
                    Icons.monitor_weight,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeItem(
    String label,
    double value,
    String unit,
    IconData icon,
  ) {
    print('_buildSizeItem: $label = $value $unit (type: ${value.runtimeType})');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '$value $unit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('กำลังโหลดข้อมูลสินค้า...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadProductDetail(forceRefresh: true),
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    if (_product == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProductPage(product: _product!),
      ),
    );

    // Only refresh if there was a successful update
    if (result == true && mounted) {
      await _loadProductDetail(forceRefresh: true);
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to trigger list refresh
      }
    }
  }

  void _showEditBasicInfoDialog() {
    if (_product == null) return;

    // Extract original name without discontinued prefix
    String originalName = _product!.skuName;
    bool isDiscontinued = originalName.startsWith('(เลิกขาย)');
    if (isDiscontinued) {
      originalName = originalName.replaceFirst('(เลิกขาย)', '').trim();
    }

    final nameController = TextEditingController(text: originalName);
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('แก้ไขข้อมูลพื้นฐาน'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อสินค้า',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ราคา (บาท)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'สถานะสินค้า:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RadioListTile<bool>(
                  title: const Text('จำหน่าย'),
                  value: false,
                  groupValue: isDiscontinued,
                  onChanged: (value) {
                    setDialogState(() {
                      isDiscontinued = value ?? false;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: const Text('เลิกขาย'),
                  value: true,
                  groupValue: isDiscontinued,
                  onChanged: (value) {
                    setDialogState(() {
                      isDiscontinued = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                // Build final name based on discontinued status
                String finalName = nameController.text.trim();
                if (isDiscontinued && !finalName.startsWith('(เลิกขาย)')) {
                  finalName = '(เลิกขาย) $finalName';
                }

                _updateBasicInfo(finalName, priceController.text);
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBasicInfo(String name, String priceStr) async {
    try {
      int? price;
      if (priceStr.isNotEmpty) {
        price = int.tryParse(priceStr);
        if (price == null) {
          _showErrorSnackBar('กรุณาใส่ราคาเป็นตัวเลข');
          return;
        }
      }

      final request = UpdateSkuMasterBasicRequest(
        skuName: name.isNotEmpty ? name : null,
        skuPrice: price,
      );

      final success = await _apiService.updateSkuMasterBasic(
        skuKey: widget.skuKey,
        request: request,
      );

      if (success) {
        Navigator.of(context).pop(); // Close dialog
        _showSuccessSnackBar('อัปเดตข้อมูลสำเร็จ');
        // Refresh data first, then return to parent page
        _loadProductDetail(forceRefresh: true).then((_) {
          print('Basic info updated, returning to parent page');
          Navigator.of(
            context,
          ).pop(true); // Return true to trigger list refresh
        });
      } else {
        _showErrorSnackBar('เกิดข้อผิดพลาดในการอัปเดต');
      }
    } catch (e) {
      _showErrorSnackBar('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดสินค้า'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_product != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: _showEditBasicInfoDialog,
              tooltip: 'แก้ไขข้อมูลพื้นฐาน',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEdit,
              tooltip: 'แก้ไขรูปภาพและขนาด',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _hasError
          ? _buildErrorWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageGallery(),
                  const SizedBox(height: 16),
                  _buildProductInfo(),
                  const SizedBox(height: 16),
                  _buildSizeDetails(),
                ],
              ),
            ),
    );
  }
}
