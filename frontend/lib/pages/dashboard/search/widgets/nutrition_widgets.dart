import 'package:flutter/material.dart';
import '../models/product_model.dart';

/// Widget displaying the nutrition grade badge
class NutritionGradeBadge extends StatelessWidget {
  final String grade;
  final double size;

  const NutritionGradeBadge({
    super.key,
    required this.grade,
    this.size = 60,
  });

  Color _getGradeColor() {
    switch (grade.toLowerCase()) {
      case 'a':
        return const Color(0xFF1E8F4E);
      case 'b':
        return const Color(0xFF60AC0E);
      case 'c':
        return const Color(0xFFFECB02);
      case 'd':
        return const Color(0xFFF39800);
      case 'e':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getGradeColor(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getGradeColor().withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          grade.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Widget displaying NOVA group processing level
class NovaGroupBadge extends StatelessWidget {
  final int novaGroup;
  final String description;

  const NovaGroupBadge({
    super.key,
    required this.novaGroup,
    required this.description,
  });

  Color _getNovaColor() {
    switch (novaGroup) {
      case 1:
        return const Color(0xFF1E8F4E);
      case 2:
        return const Color(0xFFFECB02);
      case 3:
        return const Color(0xFFF39800);
      case 4:
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getNovaColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getNovaColor(), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _getNovaColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$novaGroup',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOVA Group',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget displaying nutrient level indicator
class NutrientLevelIndicator extends StatelessWidget {
  final String nutrient;
  final String level;
  final double value;
  final String unit;

  const NutrientLevelIndicator({
    super.key,
    required this.nutrient,
    required this.level,
    required this.value,
    this.unit = 'g',
  });

  Color _getLevelColor() {
    switch (level.toLowerCase()) {
      case 'low':
        return const Color(0xFF1E8F4E);
      case 'moderate':
        return const Color(0xFFF39800);
      case 'high':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }

  IconData _getLevelIcon() {
    switch (level.toLowerCase()) {
      case 'low':
        return Icons.thumb_up;
      case 'moderate':
        return Icons.remove_circle_outline;
      case 'high':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _getLevelColor().withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            _getLevelIcon(),
            color: _getLevelColor(),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nutrient,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getLevelColor(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getLevelColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget displaying nutrition facts table
class NutritionFactsTable extends StatelessWidget {
  final Nutriments nutriments;
  final String? servingSize;

  const NutritionFactsTable({
    super.key,
    required this.nutriments,
    this.servingSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C5F2D),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Nutrient',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Per 100g',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          _buildRow('Energy', '${nutriments.energyKcal100g.toStringAsFixed(0)} kcal'),
          _buildRow('Fat', '${nutriments.fat100g.toStringAsFixed(1)} g', isAlternate: true),
          _buildRow('  Saturated Fat', '${nutriments.saturatedFat100g.toStringAsFixed(1)} g'),
          _buildRow('Carbohydrates', '${nutriments.carbohydrates100g.toStringAsFixed(1)} g', isAlternate: true),
          _buildRow('  Sugars', '${nutriments.sugars100g.toStringAsFixed(1)} g'),
          _buildRow('Proteins', '${nutriments.proteins100g.toStringAsFixed(1)} g', isAlternate: true),
          _buildRow('Salt', '${nutriments.salt100g.toStringAsFixed(2)} g', isLast: true),
          if (servingSize != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Serving Size: $servingSize',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isAlternate = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isAlternate ? Colors.grey[100] : Colors.white,
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: label.startsWith('  ') ? Colors.grey[600] : Colors.black87,
                fontWeight: label.startsWith('  ') ? FontWeight.w400 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for ingredient analysis status tags
class AnalysisTag extends StatelessWidget {
  final String label;
  final String status;
  final IconData icon;

  const AnalysisTag({
    super.key,
    required this.label,
    required this.status,
    required this.icon,
  });

  Color _getStatusColor() {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('free') ||
        statusLower == 'vegan' ||
        statusLower == 'vegetarian') {
      return const Color(0xFF1E8F4E);
    }
    if (statusLower.contains('maybe')) {
      return const Color(0xFFF39800);
    }
    if (statusLower.contains('contains') ||
        statusLower.contains('non-')) {
      return const Color(0xFFE63E11);
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _getStatusColor(), size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
