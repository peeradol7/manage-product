import 'package:flutter/material.dart';
import '../models/sku_master.dart';
import '../services/dio_service.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<SkuMasterList> _products = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Pagination info
  int _totalCount = 0;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasNextPage && !_isLoading) {
        _loadMore();
      }
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _products.clear();
        _hasError = false;
        _errorMessage = '';
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getSkuMasterList(
        page: _currentPage,
        pageSize: 20,
      );

      setState(() {
        if (refresh) {
          _products = response.data;
        } else {
          _products.addAll(response.data);
        }
        _totalPages = response.totalPages;
        _totalCount = response.totalCount;
        _hasNextPage = response.hasNextPage;
        _hasPreviousPage = response.hasPreviousPage;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_hasNextPage && !_isLoading) {
      _currentPage++;
      await _loadProducts();
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts(refresh: true);
  }

  Widget _buildProductCard(SkuMasterList product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(product.skuKey),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.skuName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Product Code
                    Text(
                      'รหัส: ${product.skuCode}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),

                    // Image Count
                    Row(
                      children: [
                        Icon(Icons.image, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${product.imageUrls.length} รูป',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
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
              onPressed: () => _loadProducts(refresh: true),
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ไม่มีสินค้า',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ยังไม่มีข้อมูลสินค้าในระบบ',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(int skuKey) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(skuKey: skuKey),
      ),
    ).then((_) {
      _refreshProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการสินค้า'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Text(
              'ทั้งหมด $_totalCount รายการ | หน้า $_currentPage จาก $_totalPages',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),

          // Content
          Expanded(
            child: _hasError
                ? _buildErrorWidget()
                : _products.isEmpty && !_isLoading
                ? _buildEmptyWidget()
                : RefreshIndicator(
                    onRefresh: _refreshProducts,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _products.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _products.length) {
                          return _buildLoadingIndicator();
                        }
                        return _buildProductCard(_products[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
