import 'package:flutter/material.dart';
import 'models/product_model.dart';
import 'widgets/expandable_section.dart';
import 'widgets/nutrition_widgets.dart';
import 'compare_product_selection_page.dart';
import 'services/inventory_service.dart';

class ProductDetailsPage extends StatelessWidget {
  final ProductDetailsResponse productDetails;

  const ProductDetailsPage({super.key, required this.productDetails});

  @override
  Widget build(BuildContext context) {
    final product = productDetails.product;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // App Bar with product image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF2C5F2D),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  icon: const Icon(Icons.compare_arrows, color: Colors.white),
                  label: const Text(
                    'Compare',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompareProductSelectionPage(
                          firstProduct: productDetails,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Product Image
                  if (product.imageUrl != null)
                    Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.fastfood,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Nutrition grade badge
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: NutritionGradeBadge(
                      grade: product.nutritionGrades,
                      size: 55,
                    ),
                  ),
                  // Add to Inventory button
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await InventoryService.addToInventory(productDetails);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.productName} added to inventory',
                                ),
                                backgroundColor: const Color(0xFF2C5F2D),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text(
                        'Add to Inventory',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5F2D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name & Categories
                  _buildProductHeader(product),

                  const SizedBox(height: 16),

                  // AI Feedback Card
                  _buildAiFeedbackCard(productDetails.aiFeedback),

                  const SizedBox(height: 16),

                  // Expandable Sections

                  // Nutrition Section
                  ExpandableSection(
                    title: 'Nutrition',
                    icon: Icons.pie_chart,
                    iconColor: const Color(0xFF2196F3),
                    initiallyExpanded: true,
                    content: _buildNutritionContent(product),
                  ),

                  // Ingredients Section
                  ExpandableSection(
                    title: 'Ingredients',
                    icon: Icons.list_alt,
                    iconColor: const Color(0xFFF39800),
                    content: _buildIngredientsContent(product),
                  ),

                  // Food Processing Section
                  ExpandableSection(
                    title: 'Food Processing',
                    icon: Icons.factory,
                    iconColor: const Color(0xFF9C27B0),
                    content: _buildProcessingContent(product),
                  ),

                  const SizedBox(height: 16),

                  // Disclaimer
                  _buildDisclaimer(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.productName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.qr_code, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                product.code,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          if (product.categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: product.categories
                  .split(',')
                  .take(3)
                  .map(
                    (category) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C5F2D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.trim(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2C5F2D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiFeedbackCard(String feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2C5F2D), const Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C5F2D).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionContent(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nutrient Levels
        const Text(
          'Nutrient Levels',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        NutrientLevelIndicator(
          nutrient: 'Fat',
          level: product.nutrientLevels.fat,
          value: product.nutriments.fat100g,
        ),
        const SizedBox(height: 8),
        NutrientLevelIndicator(
          nutrient: 'Saturated Fat',
          level: product.nutrientLevels.saturatedFat,
          value: product.nutriments.saturatedFat100g,
        ),
        const SizedBox(height: 8),
        NutrientLevelIndicator(
          nutrient: 'Sugars',
          level: product.nutrientLevels.sugars,
          value: product.nutriments.sugars100g,
        ),
        const SizedBox(height: 8),
        NutrientLevelIndicator(
          nutrient: 'Salt',
          level: product.nutrientLevels.salt,
          value: product.nutriments.salt100g,
        ),

        const SizedBox(height: 20),

        // Nutrition Facts Table
        const Text(
          'Nutrition Facts',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        NutritionFactsTable(
          nutriments: product.nutriments,
          servingSize: product.servingSize,
        ),
      ],
    );
  }

  Widget _buildIngredientsContent(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.ingredientsText != null &&
            product.ingredientsText!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              product.ingredientsText!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Ingredients information not available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Sugar Level indicator
        const Text(
          'Sugar Level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildSugarLevelIndicator(product.nutriments.sugars100g),
      ],
    );
  }

  Widget _buildSugarLevelIndicator(double sugars) {
    String level;
    Color color;

    if (sugars <= 5) {
      level = 'Low';
      color = const Color(0xFF1E8F4E);
    } else if (sugars <= 22.5) {
      level = 'Moderate';
      color = const Color(0xFFF39800);
    } else {
      level = 'High';
      color = const Color(0xFFE63E11);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$level Sugar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  '${sugars.toStringAsFixed(1)}g per 100g',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingContent(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NOVA Group
        NovaGroupBadge(
          novaGroup: product.novaGroup,
          description: product.novaGroupDescription,
        ),

        const SizedBox(height: 16),

        // Analysis Tags
        const Text(
          'Ingredient Analysis',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            AnalysisTag(
              label: 'Palm Oil',
              status: product.palmOilStatus,
              icon: Icons.eco,
            ),
            AnalysisTag(
              label: 'Vegan',
              status: product.veganStatus,
              icon: Icons.spa,
            ),
            AnalysisTag(
              label: 'Vegetarian',
              status: product.vegetarianStatus,
              icon: Icons.grass,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This analysis is based on nutrition and ingredient information only, not on processing methods. Always check the product packaging for the most accurate information.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[900],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
