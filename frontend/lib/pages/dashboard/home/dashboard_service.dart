import 'dart:convert';
import 'package:frontend/pages/dashboard/home/dashboard_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart';    

class DashboardService {
  static const String _cacheKey = 'dashboard_analysis_cache';

     
  Future<AnalysisData?> getCachedAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return AnalysisData.fromJson(jsonMap);
      } catch (e) {
        print("Cache Parsing Error: $e");
        return null;
      }
    }
    return null;
  }

     
     
  Future<AnalysisData?> fetchDashboardStats(String timeline) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return null;

    try {
      final url = Uri.parse('$apiURL/dashboard/stats?timeline=$timeline');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final analysis = AnalysisData.fromJson(data);
        
           
        await prefs.setString(_cacheKey, json.encode(analysis.toJson()));
        
        return analysis;
      } else {
        print("Dashboard API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Connection Error: $e");
      return null;
    }
  }
}