import 'dart:ui';

class GraphDataPoint {
  final String label;
  final double value;
  final Color color;

  GraphDataPoint({
    required this.label,
    required this.value,
    required this.color,
  });

  factory GraphDataPoint.fromJson(Map<String, dynamic> json) {
    return GraphDataPoint(
      label: json['label'],
      value: (json['value'] as num).toDouble(),
      color: _hexToColor(json['color']),
    );
  }

  static Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class DashboardData {
  final List<GraphDataPoint> healthBreakdown;
  final List<GraphDataPoint> macroDistribution;
  final String aiFeedback;

  DashboardData({
    required this.healthBreakdown,
    required this.macroDistribution,
    required this.aiFeedback,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      healthBreakdown: (json['health_breakdown'] as List)
          .map((e) => GraphDataPoint.fromJson(e))
          .toList(),
      macroDistribution: (json['macro_distribution'] as List)
          .map((e) => GraphDataPoint.fromJson(e))
          .toList(),
      aiFeedback: json['ai_feedback'] ?? "No feedback available.",
    );
  }
}