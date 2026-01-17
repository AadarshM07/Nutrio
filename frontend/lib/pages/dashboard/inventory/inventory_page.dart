import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/pages/constants/constants.dart';
import 'package:frontend/pages/dashboard/search/models/product_model.dart';
import 'package:frontend/pages/dashboard/search/product_details_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import your existing models and pages

class InventoryItem {
  final String barcode;
  final String title;
  final String img;
  final String tag;
  final String nutrientScore;
  final String productData;
  final String aiFeedback;

  InventoryItem({
    required this.barcode,
    required this.title,
    required this.img,
    required this.tag,
    required this.nutrientScore,
    required this.productData,
    required this.aiFeedback,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      barcode: json['barcode'],
      title: json['title'],
      img: json['img'],
      tag: json['tag'],
      nutrientScore: json['nutrient_score'] ?? '?',
      // Ensure we handle cases where product_data might be missing or empty
      productData: json['product_data'] ?? "{}", 
      aiFeedback: json['ai_feedback'] ?? "No feedback available.",
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<InventoryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return;

    try {
      // Endpoint to fetch inventory
      final url = Uri.parse('$apiURL/inv/');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _items = data.map((e) => InventoryItem.fromJson(e)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
        debugPrint("Failed to fetch inventory: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint("Error fetching inventory: $e");
    }
  }

  void _navigateToProductDetails(BuildContext context, InventoryItem item) {
    try {
      // 1. Decode the stored JSON string back into a Map
      final Map<String, dynamic> productMap = json.decode(item.productData);

      // 2. Convert the Map back into your Product model
      // Note: Make sure your Product.fromJson can handle the map structure 
      // saved in InventoryService.
      final Product product = Product.fromJson(productMap);

      // 3. Create the Details Response object expected by the page
      final detailsResponse = ProductDetailsResponse(
        product: product,
        aiFeedback: item.aiFeedback,
      );

      // 4. Navigate
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsPage(
            productDetails: detailsResponse,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening product: $e")),
      );
      debugPrint("Error parsing product data: $e");
    }
  }

  Color _getScoreColor(String score) {
    switch (score.toLowerCase()) {
      case 'a': return const Color(0xFF00A651);
      case 'b': return const Color(0xFF85BB2F);
      case 'c': return const Color(0xFFFDB913);
      case 'd': return const Color(0xFFEE7F01);
      case 'e': return const Color(0xFFE63E11);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2C5F2D)));
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Your pantry is empty", 
              style: TextStyle(color: Colors.grey[500], fontSize: 16)
            ),
            const SizedBox(height: 8),
            Text(
              "Scan products to add them here", 
              style: TextStyle(color: Colors.grey[400], fontSize: 14)
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly off-white background
      appBar: AppBar(
        title: const Text(
          "My Pantry", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.black87),
            onPressed: () {
              // Implement sort functionality if needed
            },
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70, // Adjusted ratio for better fit
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return _buildInventoryCard(item);
        },
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    return GestureDetector(
      onTap: () => _navigateToProductDetails(context, item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: item.img.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              item.img,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.fastfood, color: Colors.grey, size: 40),
                  ),
                  // Grade Badge overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.nutrientScore.toUpperCase(),
                        style: TextStyle(
                          color: _getScoreColor(item.nutrientScore),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Details Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    
                    if (item.tag.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.tag.split(',').first, // Show only first tag to save space
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.w500
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
  }
}