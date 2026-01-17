import 'package:flutter/material.dart';
import 'package:frontend/pages/survey/survey.dart'; // Import to enable navigation back to the start

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  // These fields allow the page to be dynamic based on user input
  final String height;
  final String weight;
  final String bmi;
  final List<String> conditions;

  const ProfilePage({
    super.key,
    this.height = "175",
    this.weight = "82",
    this.bmi = "26.8",
    this.conditions = const ["Diabetes Type 2", "High Cholesterol", "Gluten Free"],
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryTeal = const Color(0xFF29A38F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.arrow_back_ios, color: primaryTeal),
        title: const Text("Health Profile", 
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey[400]), 
            onPressed: () {}
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildAIHealthInsight(),
            const SizedBox(height: 32),
            const Text("Current Metrics", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMetricsSection(),
            const SizedBox(height: 32),
            _buildHealthConditionTags(),
            const SizedBox(height: 32),
            _buildSettingsList(),
          ],
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
                radius: 55,
                backgroundColor: Colors.pink[50],
                child: const Icon(Icons.person, size: 50, color: Colors.pink),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryTeal, 
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.white, width: 2)
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text('Alex Johnson', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('WEIGHT LOSS', 
                  style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
              const Text('  •  Member since June 2023', 
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
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
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14),
              children: [
                const TextSpan(text: "Your glucose levels have stabilized over the last 14 days. We've updated your dinner suggestions to focus on "),
                TextSpan(text: "high-fiber options", 
                    style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                const TextSpan(text: " to maintain this trend. Keep it up!"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Updated 2 hours ago", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("DETAILS >", 
                  style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard("Height", widget.height, "CM")),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard("Weight", widget.weight, "KG")),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard("BMI", widget.bmi, "")),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (unit.isNotEmpty) Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 2),
                child: Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthConditionTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Health Condition Tags", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // NAVIGATE BACK TO SURVEY
            IconButton(
              icon: Icon(Icons.edit_outlined, color: primaryTeal, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Survey()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Dynamic generation of tags based on passed list
            ...widget.conditions.map((condition) => _buildTag(condition, _getColorForCondition(condition))),
          ],
        ),
      ],
    );
  }

  Color _getColorForCondition(String condition) {
    if (condition.contains("Diabetes")) return Colors.teal;
    if (condition.contains("Cholesterol")) return Colors.orange;
    return Colors.green;
  }

  Widget _buildTag(String label, Color color, {bool isAction = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAction ? Colors.grey[50] : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAction ? Colors.grey[200]! : color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isAction) Icon(Icons.circle, color: color, size: 8),
          if (!isAction) const SizedBox(width: 8),
          Text(label, 
              style: TextStyle(color: isAction ? Colors.grey : color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          _buildSettingsItem(Icons.favorite_border, "Vital History", Colors.green[100]!),
          _buildSettingsItem(Icons.notifications_none, "Privacy & Notifications", Colors.orange[50]!),
          _buildSettingsItem(Icons.logout, "Log Out", Colors.red[50]!, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, Color bgColor, {bool isLogout = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: isLogout ? Colors.red : Colors.black87, size: 20),
      ),
      title: Text(title, 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, 
          color: isLogout ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      //onPressed: () {},
    );
  }
}