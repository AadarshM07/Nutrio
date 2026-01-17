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
  bool onboarding = false;
  bool isAuthenticated = false;
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Load Onboarding Status
    final prefs = await SharedPreferences.getInstance();
    bool onboarded = prefs.getBool("onboarded") ?? false;

    // 2. Initialize Auth (Load Token from Disk)
    await AuthService().initialize();

    // 3. Validate Token with Backend
    bool loggedIn = false;
    final response = await AuthService().validateToken();
    if (response.success) {
      loggedIn = true;
    }

    if (mounted) {
      setState(() {
        onboarding = onboarded;
        isAuthenticated = loggedIn;
        isLoading = false; // App is ready to render
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarded", true);
    setState(() {
      onboarding = true;
    });
  }

  void _onAuthenticated() {
    setState(() {
      isAuthenticated = true;
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
          : onboarding
              ? const Survey()//onComplete: _completeOnboarding
              : const Dashboard(),
    );
  }
}