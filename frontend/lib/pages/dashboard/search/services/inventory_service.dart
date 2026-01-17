import 'dart:convert';
import 'package:frontend/pages/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../../../constants/constants.dart';

class InventoryService {
  static const String baseUrl = '$apiURL/inv';

  static Future<bool> addToInventory(
    ProductDetailsResponse productDetails,
  ) async {
    try {
      // Get JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final product = productDetails.product;

      // Prepare product data as JSON string
      final productDataMap = {
        'categories': product.categories,
        'categories_tags': product.categoriesTags,
        'code': product.code,
        'image_url': product.imageUrl,
        'ingredients_analysis_tags': product.ingredientsAnalysisTags,
        'ingredients_text': product.ingredientsText,
        'nova_group': product.novaGroup,
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
        'nutrition_grades': product.nutritionGrades,
        'product_name': product.productName,
        'serving_size': product.servingSize,
      };

      // Get first 3 categories as tag
      final categoriesList = product.categories
          .split(',')
          .take(3)
          .map((e) => e.trim())
          .toList();
      final tag = categoriesList.join(', ');

      // Prepare request body
      final requestBody = {
        'barcode': product.code,
        'title': product.productName,
        'img': product.imageUrl ?? '',
        'tag': tag,
        'nutrient_score': product.nutritionGrades,
        'product_data': jsonEncode(productDataMap),
        'ai_feedback': productDetails.aiFeedback,
      };

      // Make API call
      final response = await http.post(
        Uri.parse('$apiURL/inv/add/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 409) {
        throw Exception('Product already exists in your inventory');
      } else {
        throw Exception('Failed to add to inventory: ${response.body}');
      }
    } catch (e) {
      print('Error adding to inventory: $e');
      rethrow;
    }
  }
}
