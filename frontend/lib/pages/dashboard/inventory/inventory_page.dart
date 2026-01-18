import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';  

 
import 'package:frontend/pages/constants/constants.dart';
import 'package:frontend/pages/dashboard/search/models/product_model.dart';
import 'package:frontend/pages/dashboard/search/product_details_page.dart';

class InventoryItem {
  final String barcode;
  final String title;
  final String img;
  final String tag;
  final String nutrientScore;
  final String productData;
  final String aiFeedback;
  final DateTime timestamp;  

  InventoryItem({
    required this.barcode,
    required this.title,
    required this.img,
    required this.tag,
    required this.nutrientScore,
    required this.productData,
    required this.aiFeedback,
    required this.timestamp,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      barcode: json['barcode'],
      title: json['title'],
      img: json['img'],
      tag: json['tag'],
      nutrientScore: json['nutrient_score'] ?? '?',
      productData: json['product_data'] ?? "{}",
      aiFeedback: json['ai_feedback'] ?? "No feedback available.",
       
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']).toLocal() 
          : DateTime.now(), 
    );
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
   
  List<InventoryItem> _allItems = [];
   
  List<InventoryItem> _filteredItems = [];
  
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

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
            _allItems = data.map((e) => InventoryItem.fromJson(e)).toList();
             
            _allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            _filterItemsByDate();
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

   
  void _filterItemsByDate() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        return item.timestamp.year == _selectedDate.year &&
               item.timestamp.month == _selectedDate.month &&
               item.timestamp.day == _selectedDate.day;
      }).toList();
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _filterItemsByDate();
  }

  void _navigateToProductDetails(BuildContext context, InventoryItem item) {
    try {
      final Map<String, dynamic> productMap = json.decode(item.productData);
      final Product product = Product.fromJson(productMap);
      final detailsResponse = ProductDetailsResponse(
        product: product,
        aiFeedback: item.aiFeedback,
      );

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
           
          _buildDateSelector(),
          
          const Divider(height: 1),

           
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C5F2D)))
              : _filteredItems.isEmpty 
                  ? _buildEmptyState()
                  : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 85,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
         
        itemCount: 33, 
        reverse: true,  
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
           
           
           
           
          
          final date = DateTime.now().subtract(Duration(days: index - 2)); 
          
          final isSelected = date.year == _selectedDate.year && 
                             date.month == _selectedDate.month && 
                             date.day == _selectedDate.day;

          final isToday = date.year == DateTime.now().year && 
                          date.month == DateTime.now().month && 
                          date.day == DateTime.now().day;

          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2C5F2D) : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2C5F2D) : Colors.grey[200]!,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: const Color(0xFF2C5F2D).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                ] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),  
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xFF2C5F2D),
                        shape: BoxShape.circle
                      ),
                    )
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lunch_dining_outlined, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            "No food logged for this day", 
            style: TextStyle(color: Colors.grey[600], fontSize: 16)
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
               
               
            },
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2C5F2D)),
            label: const Text("Scan Meal", style: TextStyle(color: Color(0xFF2C5F2D))),
          )
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _buildInventoryCard(item);
      },
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
     
    final timeString = DateFormat('h:mm a').format(item.timestamp);

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
                   
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            timeString,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                   
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
                          item.tag.split(',').first,
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