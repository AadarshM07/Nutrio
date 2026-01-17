import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/auth_page.dart';
import 'package:frontend/pages/auth/auth_service.dart';
import 'package:frontend/pages/dashboard/dashboard.dart';
import 'package:frontend/pages/survey/survey.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isAuthenticated = false;
  bool isLoading = true; 
  bool isSurveyCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Load Onboarding Status
    final prefs = await SharedPreferences.getInstance();

    // 2. Initialize Auth (Load Token from Disk)
    await AuthService().initialize();

    // 3. Validate Token with Backend
    bool loggedIn = false;
    bool surveyDone = false;
    final response = await AuthService().validateToken();
    if (response.success) {
      loggedIn = true;
      surveyDone = response.user!.isSurveyCompleted;
    }

    if (mounted) {
      setState(() {
        isAuthenticated = loggedIn;
        isSurveyCompleted = surveyDone;
        isLoading = false; // App is ready to render
      });
    }
  }

  void _onAuthenticated() {
    final user = AuthService().currentUser;
    setState(() {
      isAuthenticated = true;
      isSurveyCompleted = user?.isSurveyCompleted ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: !isAuthenticated
          ? AuthPage(onAuthenticated: _onAuthenticated)
          : !isSurveyCompleted
              ? const Survey() 
              : const Dashboard(),
    );
  }
}