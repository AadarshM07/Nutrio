class User {
  final int id;
  final String name;
  final String email;
  final int? weight;
  final int? height;
  final String? gender;
  final String? healthIssues;
  final String? dietaryPreferences;
  final String? goals;
  final String? healthDetails;    

  User({
    required this.id,
    required this.name,
    required this.email,
    this.weight,
    this.height,
    this.gender,
    this.healthIssues,
    this.dietaryPreferences,
    this.goals,
    this.healthDetails,
  });

  bool get isSurveyCompleted => gender != null && weight != null && height != null;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      weight: json['weight'],
      height: json['height'],
      gender: json['gender'],
      healthIssues: json['health_issues'],
      dietaryPreferences: json['dietary_preferences'],
      goals: json['goals'],
      healthDetails: json['health_details'],    
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'weight': weight,
      'height': height,
      'gender': gender,
      'health_issues': healthIssues,
      'dietary_preferences': dietaryPreferences,
      'goals': goals,
      'health_details': healthDetails,
    };
  }
}