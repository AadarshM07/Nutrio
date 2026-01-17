import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import '../constants/constants.dart'; 
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

  User? _currentUser; // Fixed: Added this back
  String? _currentToken;
  
  User? get currentUser => _currentUser; // Getter to access it outside

  // --- INITIALIZE (Load Token on App Start) ---
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString('auth_token');
    // We don't load user_data here because we want to validate the token first
    // in validateToken(), which ensures the data is fresh.
  }

  // --- VALIDATE & SAVE USER ---
  Future<AuthResponse> validateToken() async {
    if (_currentToken == null) {
      return AuthResponse(success: false, message: 'No token found');
    }

    try {
      final url = Uri.parse('$apiURL/auth/validate/');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_currentToken', 
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Determine type
        String type = 'user';
        if (data.containsKey('org_name')) {
          type = 'organization';
        }

        final user = User.fromJson(data, type);
        _currentUser = user;

        // --- SAVE USER DATA ---
        final prefs = await SharedPreferences.getInstance();
        // We save the user as a JSON string to 'user_data'
        await prefs.setString('user_data', json.encode(user.toJson()));

        return AuthResponse(
          success: true, 
          message: 'Session restored', 
          user: user
        );
      } else {
        // Token invalid -> Clear data
        logout();
        return AuthResponse(success: false, message: 'Session expired');
      }
    } catch (e) {
      return AuthResponse(success: false, message: 'Connection error: $e');
    }
  }

  // --- LOGIN ---
  Future<AuthResponse> login({
    required String identifier, 
    required String password,
  }) async {
    try {
      final url = Uri.parse('$apiURL/login/');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _currentToken = data['access_token'];
        
        // --- SAVE TOKEN ---
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _currentToken!);

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

  // --- REGISTER ---
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required bool isOrganization,
  }) async {
    try {
      final endpoint = isOrganization ? '/auth/organization/register/' : '/auth/register/';
      final url = Uri.parse('$apiURL$endpoint');

      Map<String, dynamic> body;
      print(apiURL);
      if (isOrganization) {
        body = {
          'org_name': username,
          'email': email,
          'password': password,
        };
      } else {
        body = {
          'username': username,
          'email': email,
          'password': password,
          'full_name': username, 
        };
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        final user = User.fromJson(
          data, 
          isOrganization ? 'organization' : 'user'
        );
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