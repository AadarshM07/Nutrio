import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'services/product_service.dart';
import 'models/product_model.dart' as local;
import 'product_details_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String initialQuery;
  final List<Product> initialResults;

  const SearchResultsPage({
    super.key,
    required this.initialQuery,
    required this.initialResults,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _searchQuery = widget.initialQuery;
    _products = widget.initialResults;
  }

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

    final results = await _productService.searchProducts(_searchQuery);

    setState(() {
      _isLoading = false;
      _products = results ?? [];
    });
  }

  Future<void> _navigateToProductDetails(Product product) async {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailsPage(productDetails: productDetails),
      ),
    );
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
          'Search Results',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search bar section
          Container(
            color: const Color(0xFF2C5F2D),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
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
                        hintText: 'Search for products...',
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: _isLoading ? null : _performSearch,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(12),
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
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
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
                        onTap: () => _navigateToProductDetails(product),
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
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getNutritionGradeColor(
                                              nutritionGrade,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Grade $nutritionGrade',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                _getNutritionGradeLabel(
                                                  nutritionGrade,
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
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
