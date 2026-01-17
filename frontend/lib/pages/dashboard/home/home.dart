import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/auth_service.dart'; // To get User Weight/Height
import 'package:frontend/pages/auth/user_model.dart';
import 'dashboard_service.dart';
import 'dashboard_model.dart';
import 'recommended_products.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onChatTapped;
  const HomePage({super.key, this.onChatTapped});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryTeal = const Color(0xFF29A38F); // Your Brand Color
  final Color darkGreen = const Color(0xFF0EAD69);   // The darker green from design card
  
  DashboardData? _dashboardData;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // Fetch both Profile (for Weight/Height) and Stats (for AI/Macros)
    final userResponse = await AuthService().validateToken();
    final statsData = await DashboardService().fetchDashboardStats();

    if (mounted) {
      setState(() {
        _user = userResponse.user;
        _dashboardData = statsData;
        _isLoading = false;
      });
    }
  }

  // Calculate BMI helper
  double _calculateBMI() {
    if (_user?.weight == null || _user?.height == null || _user!.height == 0) return 0;
    double hM = _user!.height! / 100;
    return _user!.weight! / (hM * hM);
  }

  @override
  Widget build(BuildContext context) {
    // Fallback data
    final displayData = _dashboardData ?? DashboardData(
      healthBreakdown: [],
      macroDistribution: [
        GraphDataPoint(label: "Protein", value: 45, color: Colors.blue),
        GraphDataPoint(label: "Carbs", value: 60, color: Colors.orange),
        GraphDataPoint(label: "Fats", value: 30, color: const Color(0xFF29A38F)),
      ],
      aiFeedback: "Loading insights...",
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // 2. AI Coach Insight (The Big Green Card)
          _buildAICoachCard(displayData.aiFeedback),
          
          const SizedBox(height: 32),

          // 3. Health Metrics (Weight, Height, BMI Slider)
          _buildSectionHeader("HEALTH METRICS", "UPDATE"),
          const SizedBox(height: 16),
          _buildHealthMetricsCard(),

          const SizedBox(height: 32),

          // 4. Macro Distribution (Horizontal Bars)
          _buildSectionHeader("MACRO DISTRIBUTION", "Daily Target: 2,100 kcal"),
          const SizedBox(height: 16),
          ...displayData.macroDistribution.map((m) => _buildHorizontalMacro(m)).toList(),

          const SizedBox(height: 32),

          // 5. Recommended Products
          _buildSectionHeader("RECOMMENDED FOR YOU", "VIEW ALL"),
          const SizedBox(height: 16),
          const RecommendedProducts(), 
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        Text(action, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryTeal)),
      ],
    );
  }

  Widget _buildAICoachCard(String feedback) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: darkGreen, // Matches design green
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text("AI COACH INSIGHT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Real-time", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _isLoading ? "Analyzing your vitals..." : feedback,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: widget.onChatTapped,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Open Smart Chat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHealthMetricsCard() {
    double bmi = _calculateBMI();
    String bmiText = bmi > 0 ? bmi.toStringAsFixed(1) : "--";
    
    // Determine status
    String status = "Normal";
    if(bmi > 25) status = "Overweight";
    if(bmi < 18.5) status = "Underweight";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricItem("WEIGHT (KG)", "${_user?.weight ?? '--'}", Icons.monitor_weight_outlined),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              Expanded(
                child: _buildMetricItem("HEIGHT (CM)", "${_user?.height ?? '--'}", Icons.height),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("YOUR BMI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(bmiText, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTeal)),
              const SizedBox(width: 8),
              Text(status, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 12),
          // BMI Slider Visualization
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
                    stops: [0.1, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
              // Indicator dot
              Positioned(
                left: (bmi / 40 * 300).clamp(0, 300), // Simple math to position dot roughly
                top: 0, bottom: 0,
                child: Container(
                  width: 4, height: 12,
                  color: Colors.black,
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Under", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text("Healthy", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text("Over", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text("Obese", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _buildHorizontalMacro(GraphDataPoint macro) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 10, color: macro.color),
                  const SizedBox(width: 8),
                  Text(macro.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Text("${macro.value.toInt()}g / 150g", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (macro.value / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade100,
              color: macro.color,
              minHeight: 6,
            ),
          )
        ],
      ),
    );
  }
}