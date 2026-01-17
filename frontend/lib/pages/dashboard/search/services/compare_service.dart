import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../../../constants/constants.dart';

class CompareService {
  static const String baseUrl = '$apiURL/v1';

  static Future<Map<String, dynamic>?> compareProducts(
    ProductDetailsResponse product1,
    ProductDetailsResponse product2,
  ) async {
    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Convert products to JSON format for API
      final product1Data = _productToMap(product1.product);
      final product2Data = _productToMap(product2.product);

      final requestBody = {
        'token': token,
        'product1': product1Data,
        'product2': product2Data,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/compare'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['comparison'];
        } else {
          throw Exception('Comparison failed');
        }
      } else {
        throw Exception('Failed to compare products: ${response.body}');
      }
    } catch (e) {
      print('Error comparing products: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _productToMap(Product product) {
    return {
      'product_name': product.productName,
      'code': product.code,
      'categories': product.categories,
      'categories_tags': product.categoriesTags,
      'image_url': product.imageUrl,
      'ingredients_text': product.ingredientsText,
      'ingredients_analysis_tags': product.ingredientsAnalysisTags,
      'nova_group': product.novaGroup,
      'nutrition_grades': product.nutritionGrades,
      'nutrient_levels': {
        'fat': product.nutrientLevels.fat,
        'salt': product.nutrientLevels.salt,
        'saturated-fat': product.nutrientLevels.saturatedFat,
        'sugars': product.nutrientLevels.sugars,
      },
      'nutriments': {
        'carbohydrates': product.nutriments.carbohydrates,
        'carbohydrates_100g': product.nutriments.carbohydrates100g,
        'energy-kcal': product.nutriments.energyKcal,
        'energy-kcal_100g': product.nutriments.energyKcal100g,
        'fat': product.nutriments.fat,
        'fat_100g': product.nutriments.fat100g,
        'proteins': product.nutriments.proteins,
        'proteins_100g': product.nutriments.proteins100g,
        'salt': product.nutriments.salt,
        'salt_100g': product.nutriments.salt100g,
        'saturated-fat': product.nutriments.saturatedFat,
        'saturated-fat_100g': product.nutriments.saturatedFat100g,
        'sugars': product.nutriments.sugars,
        'sugars_100g': product.nutriments.sugars100g,
        'nova-group': product.nutriments.novaGroup,
      },
      'serving_size': product.servingSize,
    };
  }
}
