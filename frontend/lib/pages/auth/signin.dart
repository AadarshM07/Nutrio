import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard/dashboard.dart';
import './auth_service.dart';
import './auth_widgets.dart';

class SignInPage extends StatefulWidget {
  final VoidCallback onTap; // Toggle to SignUp
  final VoidCallback authoriseUser; // Successful login callback

  const SignInPage({super.key, required this.onTap, required this.authoriseUser});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Controller is now generic for "Identifier"
  final _identifierController = TextEditingController(); 
  final _passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Matches the updated AuthService signature
    final response = await AuthService().login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (response.success) {
        // Success!
        widget.authoriseUser();
      } else {
        // Show error (e.g. "Invalid credentials")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Image.asset('assets/icons/BinIt.png', height: 60),
                        const SizedBox(height: 16),
                        Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text('Sign in to continue', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                  );
                },
                child: Text("Go to Second Page"),
              ),


                  // Fields
                  AuthTextField(
                    controller: _identifierController,
                    label: 'Email or Username', // Updated Label
                    icon: Icons.person_outline, // Generic icon
                    keyboardType: TextInputType.emailAddress,
                    // Relaxed validation: Just needs to be non-empty
                    validator: (val) => val == null || val.isEmpty ? 'Please enter your email or username' : null,
                  ),
                  
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) => val == null || val.isEmpty ? 'Please enter your password' : null,
                  ),

                  // Forgot Password Placeholder
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                         // TODO: Implement Forgot Password
                      }, 
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.green)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Button
                  PrimaryButton(
                    text: 'Sign In',
                    isLoading: _isLoading,
                    onPressed: _login,
                  ),

                  const SizedBox(height: 24),

                  // Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: Colors.grey[600])),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text('Sign Up', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}