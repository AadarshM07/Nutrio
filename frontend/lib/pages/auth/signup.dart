// signup.dart
import 'package:flutter/material.dart';
import './auth_service.dart';
import './auth_widgets.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onTap; 
  final VoidCallback authenticateUser; 

  const SignUpPage({super.key, required this.onTap, required this.authenticateUser});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Cleaned controllers - No Phone Number
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isOrganization = false;
  bool _isLoading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call Register
    final response = await AuthService().register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text, // Backend doesn't need confirm pw
      isOrganization: _isOrganization,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Account created! Please login."), backgroundColor: Colors.green),
        );
        widget.onTap(); // Switch to login screen
      } else {
        // Show the backend error (e.g., "Email already registered")
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Join the BinIt community today.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  // Fields
                  AuthTextField(
                    controller: _usernameController,
                    // If Organization, label is Org Name, otherwise Username
                    label: _isOrganization ? 'Organization Name' : 'Username',
                    icon: _isOrganization ? Icons.business : Icons.person_outline,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => !val!.contains('@') ? 'Invalid email' : null,
                  ),
                  // PHONE NUMBER REMOVED
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) => val!.length < 4 ? 'Min 4 chars' : null,
                  ),
                  AuthTextField(
                    controller: _confirmController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),

                  // Organization Checkbox
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _isOrganization,
                            activeColor: Colors.green,
                            side: BorderSide(color: Colors.grey.shade400, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => setState(() => _isOrganization = val ?? false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _isOrganization = !_isOrganization),
                          child: Text(
                            "I am registering an Organization",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  PrimaryButton(
                    text: 'Sign Up',
                    isLoading: _isLoading,
                    onPressed: _register,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text('Log In', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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