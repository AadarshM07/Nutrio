import 'package:openfoodfacts/openfoodfacts.dart' as off;

class NutrientLevels {
  final String fat;
  final String salt;
  final String saturatedFat;
  final String sugars;

  NutrientLevels({
    required this.fat,
    required this.salt,
    required this.saturatedFat,
    required this.sugars,
  });

  factory NutrientLevels.fromJson(Map<String, dynamic> json) {
    return NutrientLevels(
      fat: json['fat'] ?? 'unknown',
      salt: json['salt'] ?? 'unknown',
      saturatedFat: json['saturated-fat'] ?? 'unknown',
      sugars: json['sugars'] ?? 'unknown',
    );
  }
}

class Nutriments {
  final double carbohydrates;
  final double carbohydrates100g;
  final double energyKcal;
  final double energyKcal100g;
  final double fat;
  final double fat100g;
  final double proteins;
  final double proteins100g;
  final double salt;
  final double salt100g;
  final double saturatedFat;
  final double saturatedFat100g;
  final double sugars;
  final double sugars100g;
  final int novaGroup;

  Nutriments({
    required this.carbohydrates,
    required this.carbohydrates100g,
    required this.energyKcal,
    required this.energyKcal100g,
    required this.fat,
    required this.fat100g,
    required this.proteins,
    required this.proteins100g,
    required this.salt,
    required this.salt100g,
    required this.saturatedFat,
    required this.saturatedFat100g,
    required this.sugars,
    required this.sugars100g,
    required this.novaGroup,
  });

  factory Nutriments.fromJson(Map<String, dynamic> json) {
    return Nutriments(
      carbohydrates: (json['carbohydrates'] ?? 0).toDouble(),
      carbohydrates100g: (json['carbohydrates_100g'] ?? 0).toDouble(),
      energyKcal: (json['energy-kcal'] ?? 0).toDouble(),
      energyKcal100g: (json['energy-kcal_100g'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fat100g: (json['fat_100g'] ?? 0).toDouble(),
      proteins: (json['proteins'] ?? 0).toDouble(),
      proteins100g: (json['proteins_100g'] ?? 0).toDouble(),
      salt: (json['salt'] ?? 0).toDouble(),
      salt100g: (json['salt_100g'] ?? 0).toDouble(),
      saturatedFat: (json['saturated-fat'] ?? 0).toDouble(),
      saturatedFat100g: (json['saturated-fat_100g'] ?? 0).toDouble(),
      sugars: (json['sugars'] ?? 0).toDouble(),
      sugars100g: (json['sugars_100g'] ?? 0).toDouble(),
      novaGroup: (json['nova-group'] ?? 0).toInt(),
    );
  }
}

class Product {
  final String categories;
  final List<String> categoriesTags;
  final String code;
  final String? imageUrl;
  final List<String> ingredientsAnalysisTags;
  final String? ingredientsText;
  final int novaGroup;
  final NutrientLevels nutrientLevels;
  final Nutriments nutriments;
  final String nutritionGrades;
  final String productName;
  final String? servingSize;

  Product({
    required this.categories,
    required this.categoriesTags,
    required this.code,
    this.imageUrl,
    required this.ingredientsAnalysisTags,
    this.ingredientsText,
    required this.novaGroup,
    required this.nutrientLevels,
    required this.nutriments,
    required this.nutritionGrades,
    required this.productName,
    this.servingSize,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      categories: json['categories'] ?? '',
      categoriesTags: List<String>.from(json['categories_tags'] ?? []),
      code: json['code'] ?? '',
      imageUrl: json['image_url'],
      ingredientsAnalysisTags: List<String>.from(
        json['ingredients_analysis_tags'] ?? [],
      ),
      ingredientsText: json['ingredients_text'],
      novaGroup: json['nova_group'] ?? 0,
      nutrientLevels: NutrientLevels.fromJson(json['nutrient_levels'] ?? {}),
      nutriments: Nutriments.fromJson(json['nutriments'] ?? {}),
      nutritionGrades: json['nutrition_grades'] ?? '',
      productName: json['product_name'] ?? 'Unknown Product',
      servingSize: json['serving_size'],
    );
  }

  // Factory constructor to convert from OpenFoodFacts Product
  factory Product.fromOpenFoodFactsProduct(off.Product offProduct) {
    // Default nutrient levels to 'unknown' - will try to parse if available
    final nutrientLevels = NutrientLevels(
      fat: 'unknown',
      salt: 'unknown',
      saturatedFat: 'unknown',
      sugars: 'unknown',
    );

    // Convert nutriments - safely get values using getValue method
    final nutriments = Nutriments(
      carbohydrates:
          offProduct.nutriments?.getValue(
            off.Nutrient.carbohydrates,
            off.PerSize.serving,
          ) ??
          0,
      carbohydrates100g:
          offProduct.nutriments?.getValue(
            off.Nutrient.carbohydrates,
            off.PerSize.oneHundredGrams,
          ) ??
          0,
      energyKcal:
          offProduct.nutriments?.getValue(
            off.Nutrient.energyKCal,
            off.PerSize.serving,
          ) ??
          0,
      energyKcal100g:
          offProduct.nutriments?.getValue(
            off.Nutrient.energyKCal,
            off.PerSize.oneHundredGrams,
          ) ??
          0,
      fat:
          offProduct.nutriments?.getValue(
            off.Nutrient.fat,
            off.PerSize.serving,
          ) ??
          0,
      fat100g:
          offProduct.nutriments?.getValue(
            off.Nutrient.fat,
            off.PerSize.oneHundredGrams,
          ) ??
          0,
      proteins:
          offProduct.nutriments?.getValue(
            off.Nutrient.proteins,
            off.PerSize.serving,
          ) ??
          0,
      proteins100g:
          offProduct.nutriments?.getValue(
            off.Nutrient.proteins,
            off.PerSize.oneHundredGrams,
          ) ??
          0,
      salt:
          offProduct.nutriments?.getValue(
            off.Nutrient.salt,
            off.PerSize.serving,
          ) ??
          0,
      salt100g:
          offProduct.nutriments?.getValue(
            off.Nutrient.salt,
            off.PerSize.oneHundredGrams,
          ) ??
          0,
      saturatedFat:
          offProduct.nutriments?.getValue(
            off.Nutrient.saturatedFat,
            off.PerSize.serving,
          ) ??
          0,
      saturatedFat100g:
          offProduct.nutriments?.getValue(
            off.Nutrient.saturatedFat,
            off.PerSize.oneHundredGrams,
          ) ??
          0,
      sugars:
          offProduct.nutriments?.getValue(
            off.Nutrient.sugars,
            off.PerSize.serving,
          ) ??
          0,
      sugars100g:
          offProduct.nutriments?.getValue(
            off.Nutrient.sugars,
            off.PerSize.oneHundredGrams,
          ) ??
          0,
      novaGroup: offProduct.novaGroup ?? 0,
    );

    // Get ingredients analysis tags - simplified version
    List<String> getAnalysisTags() {
      List<String> result = [];
      try {
        if (offProduct.ingredientsAnalysisTags?.veganStatus != null) {
          result.add(
            'en:${offProduct.ingredientsAnalysisTags!.veganStatus!.offTag}',
          );
        }
        if (offProduct.ingredientsAnalysisTags?.vegetarianStatus != null) {
          result.add(
            'en:${offProduct.ingredientsAnalysisTags!.vegetarianStatus!.offTag}',
          );
        }
        if (offProduct.ingredientsAnalysisTags?.palmOilFreeStatus != null) {
          result.add(
            'en:${offProduct.ingredientsAnalysisTags!.palmOilFreeStatus!.offTag}',
          );
        }
      } catch (e) {
        print('Error parsing analysis tags: $e');
      }
      return result;
    }

    return Product(
      categories: offProduct.categories ?? '',
      categoriesTags: offProduct.categoriesTags ?? [],
      code: offProduct.barcode ?? '',
      imageUrl: offProduct.imageFrontUrl,
      ingredientsAnalysisTags: getAnalysisTags(),
      ingredientsText: offProduct.ingredientsText,
      novaGroup: offProduct.novaGroup ?? 0,
      nutrientLevels: nutrientLevels,
      nutriments: nutriments,
      nutritionGrades: offProduct.nutriscore?.toUpperCase() ?? '',
      productName: offProduct.productName ?? 'Unknown Product',
      servingSize: offProduct.servingSize,
    );
  }

  // Helper methods for ingredient analysis
  bool get hasPalmOil =>
      ingredientsAnalysisTags.any((tag) => tag.contains('palm-oil'));

  bool get isPalmOilFree =>
      ingredientsAnalysisTags.any((tag) => tag.contains('palm-oil-free'));

  String get palmOilStatus {
    if (isPalmOilFree) return 'Palm Oil Free';
    if (hasPalmOil) return 'Contains Palm Oil';
    return 'Unknown';
  }

  String get veganStatus {
    if (ingredientsAnalysisTags.any((tag) => tag == 'en:vegan')) return 'Vegan';
    if (ingredientsAnalysisTags.any((tag) => tag == 'en:non-vegan')) {
      return 'Non-Vegan';
    }
    if (ingredientsAnalysisTags.any((tag) => tag == 'en:maybe-vegan')) {
      return 'Maybe Vegan';
    }
    return 'Unknown';
  }

  String get vegetarianStatus {
    if (ingredientsAnalysisTags.any((tag) => tag == 'en:vegetarian')) {
      return 'Vegetarian';
    }
    if (ingredientsAnalysisTags.any((tag) => tag == 'en:non-vegetarian')) {
      return 'Non-Vegetarian';
    }
    if (ingredientsAnalysisTags.any((tag) => tag == 'en:maybe-vegetarian')) {
      return 'Maybe Vegetarian';
    }
    return 'Unknown';
  }

  String get novaGroupDescription {
    switch (novaGroup) {
      case 1:
        return 'Unprocessed or minimally processed foods';
      case 2:
        return 'Processed culinary ingredients';
      case 3:
        return 'Processed foods';
      case 4:
        return 'Ultra-processed food and drink products';
      default:
        return 'Unknown processing level';
    }
  }
}

class ProductDetailsResponse {
  final Product product;
  final String aiFeedback;

  ProductDetailsResponse({required this.product, required this.aiFeedback});

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      product: Product.fromJson(json['product'] ?? {}),
      aiFeedback: json['aifeedback'] ?? '',
    );
  }
}
