import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/auth_page.dart';
import 'package:frontend/pages/auth/auth_service.dart';
import 'package:frontend/pages/auth/user_model.dart';
import 'package:frontend/pages/dashboard/dashboard.dart'; // Import Dashboard
import 'package:frontend/pages/survey/survey.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryTeal = const Color(0xFF29A38F);
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await AuthService().validateToken();
    if (mounted) {
      setState(() {
        _user = response.user;
        _isLoading = false;
      });
    }
  }

  // --- FIXED LOGOUT LOGIC ---
  Future<void> _handleLogout() async {
    await AuthService().logout();
    if (mounted) {
      // Navigate to AuthPage, but provide a REAL callback this time
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AuthPage(
            onAuthenticated: () {
              // This is what happens when they log back in
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            },
          ),
        ),
        (route) => false,
      );
    }
  }

  String _calculateBMI(int? weight, int? height) {
    if (weight == null || height == null || height == 0) return "--";
    double hM = height / 100;
    double bmi = weight / (hM * hM);
    return bmi.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF29A38F))),
      );
    }

    if (_user == null) {
      return const Scaffold(body: Center(child: Text("Failed to load profile")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 30),
              _buildAIHealthInsight(),
              const SizedBox(height: 32),
              
              const Text("Physical Metrics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildMetricsRow(),

              const SizedBox(height: 32),
              const Text("Personal Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildPersonalDetailsCard(),

              const SizedBox(height: 32),
              const Text("Health & Diet Tags", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTagsSection(),

              const SizedBox(height: 32),
              if (_user!.healthDetails != null && _user!.healthDetails!.isNotEmpty) ...[
                const Text("Medical Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildDetailsCard(),
                const SizedBox(height: 32),
              ],

              // --- NEW UPDATE BUTTON ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Survey()),
                    );
                  },
                  icon: Icon(Icons.edit, color: primaryTeal),
                  label: Text("Update Medical Info", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: primaryTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSettingsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: primaryTeal.withOpacity(0.1),
                child: Text(
                  _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : "U",
                  style: TextStyle(fontSize: 40, color: primaryTeal, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryTeal, 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.white, width: 2)
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(_user!.name, 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(_user!.email, 
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAIHealthInsight() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text("AI HEALTH INSIGHT", 
                  style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Your profile is complete! Based on your goal and conditions, we've calibrated your daily recommendations.",
            style: TextStyle(color: Colors.black87, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    String bmi = _calculateBMI(_user!.weight, _user!.height);
    return Row(
      children: [
        Expanded(child: _buildInfoBox("Height", "${_user!.height ?? '--'}", "CM")),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoBox("Weight", "${_user!.weight ?? '--'}", "KG")),
        const SizedBox(width: 12),
        Expanded(child: _buildInfoBox("BMI", bmi, "")),
      ],
    );
  }

  Widget _buildPersonalDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildRowItem("Gender", _user!.gender ?? "Not specified", Icons.person_outline),
          const Divider(height: 24),
          _buildRowItem("Primary Goal", _user!.goals ?? "General Health", Icons.flag_outlined),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[800], size: 20),
              const SizedBox(width: 8),
              Text("Additional Details", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _user!.healthDetails!,
            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    List<String> tags = [];
    if (_user!.dietaryPreferences != null) tags.addAll(_user!.dietaryPreferences!.split(','));
    if (_user!.healthIssues != null) tags.addAll(_user!.healthIssues!.split(','));
    
    tags = tags.map((e) => e.trim()).where((e) => e.isNotEmpty && e != 'None').toSet().toList();

    if (tags.isEmpty) {
      return Text("No specific tags.", style: TextStyle(color: Colors.grey[400]));
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tags.map((tag) => _buildTagChip(tag)).toList(),
    );
  }

  Widget _buildTagChip(String label) {
    Color color = primaryTeal;
    if (label.toLowerCase().contains('diabetes')) color = Colors.blue;
    if (label.toLowerCase().contains('vegan')) color = Colors.green;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label, 
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (unit.isNotEmpty) Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        )
      ],
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.logout, color: Colors.red),
        ),
        title: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        onTap: _handleLogout,
      ),
    );
  }
}