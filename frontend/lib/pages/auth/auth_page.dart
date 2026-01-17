import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/auth_service.dart';
import 'package:frontend/pages/auth/signin.dart';
import 'package:frontend/pages/auth/signup.dart';
import 'package:frontend/pages/survey/survey.dart';

class AuthPage extends StatefulWidget {
   final VoidCallback onAuthenticated;
  const AuthPage({super.key, required this.onAuthenticated});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Initially, show the sign-in page
  bool showSignInPage = true;

  // Method to toggle between the two pages
  void toggleScreens() {
    setState(() {
      showSignInPage = !showSignInPage;
    });
  }
  Future<void> authoriseUser() async{
    final response = await AuthService().validateToken();
if (response.success && response.user != null) {
      // Check if survey is completed using the getter we added to User model
      if (response.user!.isSurveyCompleted) {
        widget.onAuthenticated(); // Go to Dashboard
      } else {
        // Survey incomplete: Navigate to Survey Step 1
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Survey()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showSignInPage) {
      return SignInPage(onTap: toggleScreens, authoriseUser: authoriseUser,);
    } else {
      return SignUpPage(onTap: toggleScreens,authenticateUser: authoriseUser,);
    }
  }
}