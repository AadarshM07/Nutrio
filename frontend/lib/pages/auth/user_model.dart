class User {
  final int id;
  final String username; // Holds 'username' for users OR 'org_name' for organizations
  final String email;
  final String userType; // 'user' or 'organization'
  final int? credits;    // Only for users

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
    this.credits,
  });

  // Factory to create User from JSON (Backend response OR Local Storage)
  factory User.fromJson(Map<String, dynamic> json, String type) {
    return User(
      id: json['id'] ?? 0,
      // Logic: Try 'username', if null try 'org_name', if both null use empty string
      username: json['username'] ?? json['org_name'] ?? '', 
      email: json['email'] ?? '',
      userType: type,
      credits: json['credits'],
    );
  }

  // Method to convert User to JSON (For saving to SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'user_type': userType, // Important to save this to know the type later
      'credits': credits,
      // We specifically add 'org_name' if it's an organization 
      // so checks like data.containsKey('org_name') still work on the saved data
      if (userType == 'organization') 'org_name': username,
    };
  }
}