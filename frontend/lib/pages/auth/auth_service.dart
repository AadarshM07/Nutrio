import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart'; // Ensure apiURL is defined here (e.g., http://10.0.2.2:8000)
import 'user_model.dart';

class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;

  AuthResponse({
    required this.success, 
    required this.message, 
    this.user, 
    this.token,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  String? _currentToken;
  
  User? get currentUser => _currentUser;

  // --- INITIALIZE ---
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString('auth_token');
  }

  // --- VALIDATE (GET /me/) ---
  Future<AuthResponse> validateToken() async {
    if (_currentToken == null) {
      return AuthResponse(success: false, message: 'No token found');
    }

    try {
      // Assuming your router prefix is /auth based on tokenUrl="auth/login"
      final url = Uri.parse('$apiURL/auth/me/');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_currentToken', 
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        _currentUser = user;

        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(user.toJson()));

        return AuthResponse(success: true, message: 'Session restored', user: user);
      } else {
        logout();
        return AuthResponse(success: false, message: 'Session expired');
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Connection error: $e');
    }
  }

  // --- LOGIN (POST /login/) ---
  Future<AuthResponse> login({
    required String email, 
    required String password,
  }) async {
    try {
      final url = Uri.parse('$apiURL/auth/login/');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _currentToken = data['access_token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _currentToken!);
        
        // After login, fetch user details immediately
        await validateToken();

        return AuthResponse(
          success: true, 
          message: 'Login Successful', 
          token: _currentToken
        );
      } else {
        return AuthResponse(
          success: false, 
          message: data['detail'] ?? 'Login failed'
        );
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Connection error: $e');
    }
  }

  // --- REGISTER (POST /register/) ---
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$apiURL/auth/register/');

      // Matches Pydantic RegisterRequest: name, email, password
      final body = {
        'name': name,
        'email': email,
        'password': password,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // Backend returns UserResponse
        final user = User.fromJson(data);
        return AuthResponse(success: true, message: 'Registration Successful', user: user);
      } else {
        return AuthResponse(success: false, message: data['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Connection error: $e');
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    _currentUser = null;
    _currentToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}