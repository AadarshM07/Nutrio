import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import './auth_service.dart';
import './auth_widgets.dart';

class SignInPage extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback authoriseUser;

  const SignInPage({super.key, required this.onTap, required this.authoriseUser});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();
  
  // Define the Primary Color from your palette
  final Color primaryColor = const Color(0xFF29A38F);

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await AuthService().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (response.success) {
        widget.authoriseUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2), 
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: const BoxDecoration(
                                    color: Colors.white, 
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: const Image(image: AssetImage("assets/logo_v2.png")),
                                ),
                                const SizedBox(height: 16),
                                
                                const Text(
                                  'Nutrio', 
                                  style: TextStyle(
                                    fontSize: 32, 
                                    fontWeight: FontWeight.bold, 
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  )
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Helping you make the RIGHT choices.', 
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14, 
                                    color: Colors.white.withOpacity(0.9), 
                                    fontWeight: FontWeight.w500
                                  )
                                ),
                                const SizedBox(height: 32),

                                AuthTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) => (val == null || !val.contains('@')) ? 'Please enter a valid email' : null,
                                ),
                                
                                AuthTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  validator: (val) => val == null || val.isEmpty ? 'Please enter your password' : null,
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {}, 
                                    child: const Text(
                                      'Forgot Password?', 
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold) 
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                PrimaryButton(
                                  text: 'Login',
                                  isLoading: _isLoading,
                                  onPressed: _login,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New to NutriAI? ", 
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 15,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 5)]
                            )
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              'Sign Up', 
                              style: TextStyle(
                                // UPDATED: Primary Color
                                color: primaryColor, 
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                shadows: [const Shadow(color: Colors.black45, blurRadius: 5)]
                              )
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}