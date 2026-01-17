import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;
import '../../../constants/constants.dart';
import '../models/product_model.dart' as local;

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
        body: json.encode({'token': token, 'barcode': barcode}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final productDetails = local.ProductDetailsResponse.fromJson(data);

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

  /// Searches for products by text query using Open Food Facts API
  Future<List<off.Product>?> searchProducts(String query) async {
    // 1. Create the configuration
    final off.ProductSearchQueryConfiguration configuration =
        off.ProductSearchQueryConfiguration(
          parametersList: <off.Parameter>[
            off.SearchTerms(terms: [query]), // Search by name
            const off.PageSize(size: 20), // Limit results to 20
          ],
          // 2. Select only the fields you need (crucial for speed)
          fields: [
            off.ProductField.NAME,
            off.ProductField.BARCODE,
            off.ProductField.IMAGE_FRONT_URL,
            off.ProductField.NUTRISCORE,
            off.ProductField.INGREDIENTS_TEXT,
            off.ProductField.NUTRIENT_LEVELS,
            off.ProductField.NUTRIMENTS,
            off.ProductField.CATEGORIES_TAGS,
            off.ProductField.NOVA_GROUP,
            off.ProductField.INGREDIENTS_ANALYSIS_TAGS,
          ],
          language: off.OpenFoodFactsLanguage.ENGLISH,
          version: off.ProductQueryVersion.v3,
        );

    try {
      // 3. Execute the search
      final off.SearchResult result =
          await off.OpenFoodAPIClient.searchProducts(
            null, // No user login required for searching
            configuration,
          );

      return result.products;
    } catch (e) {
      print('Error fetching products: $e');
      return null;
    }
  }

  /// Searches for products by text query using Open Food Facts API
  Future<ProductServiceResponse> searchProductByText(String searchQuery) async {
    try {
      final fields =
          "product_name,brands,nutrition_grades,nutriments,image_url,code,"
          "nutrient_levels,serving_size,ingredients_text,nova_group,"
          "ingredients_analysis_tags,categories_tags,categories";

      final url = Uri.parse(
        'https://world.openfoodfacts.net/api/v2/search?search_terms=$searchQuery&fields=$fields',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List<dynamic>?;

        if (products != null && products.isNotEmpty) {
          // Get the first product
          final firstProduct = products[0] as Map<String, dynamic>;

          // Convert Open Food Facts format to our ProductDetailsResponse format
          final product = local.Product.fromJson(firstProduct);

          // Create a ProductDetailsResponse with empty AI feedback
          // since Open Food Facts doesn't provide that
          final productDetails = local.ProductDetailsResponse(
            product: product,
            aiFeedback: '',
          );

          return ProductServiceResponse(
            success: true,
            message: 'Product found',
            data: productDetails,
          );
        } else {
          return ProductServiceResponse(
            success: false,
            message: 'No products found matching "$searchQuery"',
          );
        }
      } else {
        return ProductServiceResponse(
          success: false,
          message: 'Failed to search products',
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
  final local.ProductDetailsResponse? data;

  ProductServiceResponse({
    required this.success,
    required this.message,
    this.data,
  });
}
