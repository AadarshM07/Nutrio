import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart'; 

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatService {
     
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

     
  Future<ChatMessage?> sendMessage(String message) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final url = Uri.parse('$apiURL/chat/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',    
        },
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
           
        return ChatMessage(
          text: data['response'],
          isUser: false,
          timestamp: DateTime.parse(data['timestamp']),
        );
      } else {
        print('Error sending message: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Connection error: $e');
      return null;
    }
  }

     
  Future<List<ChatMessage>> getHistory() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final url = Uri.parse('$apiURL/chat/history');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<ChatMessage> history = [];

           
           
        for (var item in data) {
          final time = DateTime.parse(item['timestamp']);
          
             
          history.add(ChatMessage(
            text: item['message'],
            isUser: true,
            timestamp: time,
          ));

             
          history.add(ChatMessage(
            text: item['response'],
            isUser: false,
            timestamp: time.add(const Duration(milliseconds: 100)),
          ));
        }
        return history;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }
}