import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/constants.dart';
import '../models/product_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Fetches product details by barcode from the API
  Future<ProductServiceResponse> getProductDetails(String barcode) async {
    final token = await _getToken();
    
    if (token == null) {
      return ProductServiceResponse(
        success: false,
        message: 'Authentication required. Please log in.',
      );
    }

    try {
      final url = Uri.parse('$apiURL/v1/details');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'token': token,
          'barcode': barcode,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final productDetails = ProductDetailsResponse.fromJson(data);
        
        return ProductServiceResponse(
          success: true,
          message: 'Product found',
          data: productDetails,
        );
      } else if (response.statusCode == 404) {
        return ProductServiceResponse(
          success: false,
          message: 'Product not found in database',
        );
      } else if (response.statusCode == 401) {
        return ProductServiceResponse(
          success: false,
          message: 'Session expired. Please log in again.',
        );
      } else {
        return ProductServiceResponse(
          success: false,
          message: 'Failed to fetch product details',
        );
      }
    } catch (e) {
      return ProductServiceResponse(
        success: false,
        message: 'Connection error: $e',
      );
    }
  }
}

class ProductServiceResponse {
  final bool success;
  final String message;
  final ProductDetailsResponse? data;

  ProductServiceResponse({
    required this.success,
    required this.message,
    this.data,
  });
}
