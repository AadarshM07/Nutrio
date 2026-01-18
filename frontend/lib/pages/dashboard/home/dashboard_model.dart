class AnalysisData {
  final int healthScore;
  final String predictionSummary;
  final ImpactAnalysis moodAnalysis;
  final ImpactAnalysis bodyAnalysis;
  final List<KeyNutrient> keyNutrients;
  final String recommendation;

  AnalysisData({
    required this.healthScore,
    required this.predictionSummary,
    required this.moodAnalysis,
    required this.bodyAnalysis,
    required this.keyNutrients,
    required this.recommendation,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    return AnalysisData(
      healthScore: json['health_score'] ?? 0,
      predictionSummary: json['prediction_summary'] ?? "No prediction available.",
      moodAnalysis: ImpactAnalysis.fromJson(json['mood_analysis'] ?? {}),
      bodyAnalysis: ImpactAnalysis.fromJson(json['body_analysis'] ?? {}),
      keyNutrients: (json['key_nutrients'] as List? ?? [])
          .map((e) => KeyNutrient.fromJson(e))
          .toList(),
      recommendation: json['recommendation'] ?? "Keep tracking your inventory to get insights.",
    );
  }

  // NEW: Required for saving to SharedPrefs
  Map<String, dynamic> toJson() => {
    'health_score': healthScore,
    'prediction_summary': predictionSummary,
    'mood_analysis': moodAnalysis.toJson(),
    'body_analysis': bodyAnalysis.toJson(),
    'key_nutrients': keyNutrients.map((e) => e.toJson()).toList(),
    'recommendation': recommendation,
  };
}

class ImpactAnalysis {
  final String state;
  final String mechanism;

  ImpactAnalysis({required this.state, required this.mechanism});

  factory ImpactAnalysis.fromJson(Map<String, dynamic> json) {
    return ImpactAnalysis(
      state: json['state'] ?? "Unknown",
      mechanism: json['mechanism'] ?? "Insufficient data.",
    );
  }

  Map<String, dynamic> toJson() => {
    'state': state,
    'mechanism': mechanism,
  };
}

class KeyNutrient {
  final String nutrient;
  final String status;
  final String impact;

  KeyNutrient({required this.nutrient, required this.status, required this.impact});

  factory KeyNutrient.fromJson(Map<String, dynamic> json) {
    return KeyNutrient(
      nutrient: json['nutrient'] ?? "Nutrient",
      status: json['status'] ?? "Normal",
      impact: json['impact'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'nutrient': nutrient,
    'status': status,
    'impact': impact,
  };
}