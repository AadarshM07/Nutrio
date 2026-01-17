import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'services/product_service.dart';
import 'services/compare_service.dart';
import 'models/product_model.dart' as local;
import 'barcode_scanner_page.dart';
import 'product_not_found_page.dart';
import 'comparison_result_page.dart';

class CompareProductSelectionPage extends StatefulWidget {
  final local.ProductDetailsResponse firstProduct;

  const CompareProductSelectionPage({super.key, required this.firstProduct});

  @override
  State<CompareProductSelectionPage> createState() =>
      _CompareProductSelectionPageState();
}

class _CompareProductSelectionPageState
    extends State<CompareProductSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Determine if the query is a barcode (numeric) or text search
    final isBarcode = RegExp(r'^[0-9]+$').hasMatch(_searchQuery);

    if (isBarcode) {
      // Barcode search - get single product from backend
      final response = await _productService.getProductDetails(_searchQuery);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (response.success && response.data != null) {
        // Navigate to comparison page with both products
        _navigateToComparison(response.data!);
      } else {
        // Show not found page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductNotFoundPage(searchQuery: _searchQuery),
          ),
        );
      }
    } else {
      // Text search - get multiple products
      final results = await _productService.searchProducts(_searchQuery);

      setState(() {
        _isLoading = false;
        _products = results ?? [];
      });

      if (_products.isEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductNotFoundPage(searchQuery: _searchQuery),
          ),
        );
      }
    }
  }

  Future<void> _openBarcodeScanner() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
    );

    if (scannedCode != null && mounted) {
      setState(() {
        _searchController.text = scannedCode;
        _searchQuery = scannedCode;
      });
      _performSearch();
    }
  }

  void _navigateToComparison(local.ProductDetailsResponse secondProduct) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF2C5F2D)),
                SizedBox(height: 16),
                Text(
                  'Analyzing products...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final comparisonResult = await CompareService.compareProducts(
        widget.firstProduct,
        secondProduct,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (comparisonResult != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComparisonResultPage(
              firstProduct: widget.firstProduct,
              secondProduct: secondProduct,
              comparisonData: comparisonResult,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to compare products. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToProductForComparison(Product product) async {
    setState(() {
      _isLoading = true;
    });

    // Convert OpenFoodFacts Product to our local Product model
    final localProduct = local.Product.fromOpenFoodFactsProduct(product);
    final productDetails = local.ProductDetailsResponse(
      product: localProduct,
      aiFeedback: '',
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    _navigateToComparison(productDetails);
  }

  String _getNutritionGrade(Product product) {
    if (product.nutriscore != null && product.nutriscore!.isNotEmpty) {
      return product.nutriscore!.toUpperCase();
    }
    return 'N/A';
  }

  Color _getNutritionGradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return const Color(0xFF00A651);
      case 'b':
        return const Color(0xFF85BB2F);
      case 'c':
        return const Color(0xFFFDB913);
      case 'd':
        return const Color(0xFFEE7F01);
      case 'e':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }

  String _getNutritionGradeLabel(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return 'Best for Health';
      case 'b':
        return 'Healthy Choice';
      case 'c':
        return 'Consume in Moderation';
      case 'd':
        return 'Limit Consumption';
      case 'e':
        return 'Avoid Frequent Consumption';
      default:
        return 'Not Rated';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C5F2D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Product to Compare',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Currently selected product banner
          Container(
            color: const Color(0xFF2C5F2D),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Current product info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (widget.firstProduct.product.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.firstProduct.product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 25),
                                ),
                          ),
                        )
                      else
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.fastfood, size: 25),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Comparing with:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.firstProduct.product.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Search bar with camera icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          onSubmitted: (_) => _performSearch(),
                          decoration: InputDecoration(
                            hintText: 'Search or scan product...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      // Camera icon button
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: _isLoading ? null : _openBarcodeScanner,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: Colors.grey[700],
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // Search button
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: _isLoading ? null : _performSearch,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2C5F2D),
                              shape: BoxShape.circle,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Results count
          if (_products.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Found ${_products.length} products',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // Grid view
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2C5F2D)),
                  )
                : _products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Search for a product to compare',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Type a product name or scan barcode',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final nutritionGrade = _getNutritionGrade(product);

                      return GestureDetector(
                        onTap: () => _navigateToProductForComparison(product),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: product.imageFrontUrl != null
                                      ? Image.network(
                                          product.imageFrontUrl!,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 40,
                                                    color: Colors.grey[400],
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.fastfood,
                                            size: 40,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                ),
                              ),
                              // Product Info
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Name
                                      Text(
                                        product.productName ??
                                            'Unknown Product',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.2,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Nutrition Grade Badge
                                      if (nutritionGrade != 'N/A')
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getNutritionGradeColor(
                                              nutritionGrade,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            'Grade $nutritionGrade',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
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
        ],
      ),
    );
  }
}
