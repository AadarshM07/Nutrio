import 'dart:ui'; // Required for ImageFilter
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
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Define the Primary Color from your palette
  final Color primaryColor = const Color(0xFF29A38F); 

  bool _isChecked = false; 
  bool _isLoading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms and Privacy Policy"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await AuthService().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Account created! Logging you in..."), backgroundColor: Colors.green),
        );
        widget.onTap(); 
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: widget.onTap,
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              decoration: const BoxDecoration(
                                color: Colors.white, 
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Image(image: AssetImage("assets/logo_v2.png")),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Create Account', 
                              style: TextStyle(
                                fontSize: 28, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white,
                                letterSpacing: 0.5
                              )
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start your personalized nutrition journey.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                            ),
                            const SizedBox(height: 32),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2), 
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                      const SizedBox(height: 8),
                                      AuthTextField(
                                        controller: _nameController,
                                        label: 'Enter your name',
                                        icon: Icons.person_outline,
                                        validator: (val) => val!.isEmpty ? 'Name is required' : null,
                                      ),

                                      const SizedBox(height: 16),
                                      const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                      const SizedBox(height: 8),
                                      AuthTextField(
                                        controller: _emailController,
                                        label: 'name@example.com',
                                        icon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (val) => !val!.contains('@') ? 'Invalid email' : null,
                                      ),

                                      const SizedBox(height: 16),
                                      const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                      const SizedBox(height: 8),
                                      AuthTextField(
                                        controller: _passwordController,
                                        label: 'Create a strong password',
                                        icon: Icons.lock_outline,
                                        isPassword: true,
                                        validator: (val) => val!.length < 4 ? 'Min 4 chars' : null,
                                      ),

                                      const SizedBox(height: 16),

                                      // Terms Checkbox
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              value: _isChecked,
                                              // UPDATED: Primary Color
                                              activeColor: primaryColor, 
                                              side: const BorderSide(color: Colors.white, width: 2),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                              onChanged: (val) => setState(() => _isChecked = val ?? false),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Wrap(
                                              children: [
                                                const Text("I agree to the ", style: TextStyle(color: Colors.white, fontSize: 13)),
                                                // UPDATED: Primary Color
                                                Text("Terms of Service ", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                                const Text("and ", style: TextStyle(color: Colors.white, fontSize: 13)),
                                                // UPDATED: Primary Color
                                                Text("Privacy Policy.", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 24),

                                      PrimaryButton(
                                        text: 'Create Account',
                                        isLoading: _isLoading,
                                        onPressed: _register,
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
                                Text("Already have an account? ", 
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    shadows: [Shadow(color: Colors.black45, blurRadius: 5)]
                                  )
                                ),
                                GestureDetector(
                                  onTap: widget.onTap,
                                  child: Text('Log In', 
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
          ),
        ],
      ),
    );
  }
}