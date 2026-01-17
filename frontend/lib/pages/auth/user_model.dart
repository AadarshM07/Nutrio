class User {
  final int id;
  final String name;
  final String email;
  final String? gender;
  final String? healthIssues;
  final String? dietaryPreferences;
  final String? goals;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    this.healthIssues,
    this.dietaryPreferences,
    this.goals,
  });

  // Factory to create User from Backend JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'],
      healthIssues: json['health_issues'],
      dietaryPreferences: json['dietary_preferences'],
      goals: json['goals'],
    );
  }

  // Method to convert User to JSON (For saving to SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'health_issues': healthIssues,
      'dietary_preferences': dietaryPreferences,
      'goals': goals,
    };
  }
}