import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/auth_service.dart';
import 'package:frontend/pages/auth/user_model.dart';
import 'package:frontend/pages/dashboard/home/dashboard_model.dart';
import 'package:frontend/pages/dashboard/home/dashboard_service.dart';
import 'package:frontend/pages/dashboard/home/recommended_products.dart';


class HomePage extends StatefulWidget {
  final VoidCallback? onChatTapped;
  const HomePage({super.key, this.onChatTapped});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Brand Colors
  final Color primaryTeal = const Color(0xFF29A38F);
  final Color darkGreen = const Color(0xFF0EAD69);
  final Color bgGrey = const Color(0xFFF8F9FA);

  AnalysisData? _analysisData;
  User? _user;
  bool _isLoading = true;
  String _selectedTimeline = '1 year';
  final DashboardService _service = DashboardService();

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  /// Load User Profile + Cached Dashboard Data
  Future<void> _initialLoad() async {
    setState(() => _isLoading = true);

    // 1. Get User info (for BMI)
    final userResponse = await AuthService().validateToken();
    
    // 2. Check Cache for previous Analysis
    final cachedData = await _service.getCachedAnalysis();

    if (mounted) {
      setState(() {
        _user = userResponse.user;
        _analysisData = cachedData; // Populates dashboard if cache exists
        _isLoading = false;
      });
    }
  }

  /// Fetch Fresh Data from API (Triggered by Button or Timeline change)
  Future<void> _runAnalysis() async {
    setState(() => _isLoading = true);
    
    final freshData = await _service.fetchDashboardStats(_selectedTimeline);
    
    if (mounted) {
      setState(() {
        if (freshData != null) {
          _analysisData = freshData;
        }
        _isLoading = false;
      });
    }
  }

  double _calculateBMI() {
    if (_user?.weight == null || _user?.height == null || _user!.height == 0) return 0;
    double hM = _user!.height! / 100;
    return _user!.weight! / (hM * hM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            _buildHeader(),
            const SizedBox(height: 24),

            // --- 1. HEALTH METRICS (Always Visible) ---
            _buildSectionHeader("HEALTH METRICS"),
            const SizedBox(height: 12),
            _buildHealthMetricsCard(),
            const SizedBox(height: 24),

            // --- 2. AI PREDICTION SECTION ---
            if (_isLoading)
              _buildLoadingState()
            else if (_analysisData == null)
              _buildEmptyState() // Shows "Analyze Now" button if no cache
            else
              _buildDashboardContent(), // Shows Graphs & Data

            // --- 3. RECOMMENDED PRODUCTS ---
            const SizedBox(height: 24),
            _buildSectionHeader("RECOMMENDED PRODUCTS"),
            const SizedBox(height: 12),
            const RecommendedProducts(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(Icons.auto_graph_outlined, size: 64, color: primaryTeal.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "No Analysis Yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Let our AI analyze your inventory habits to predict your health trajectory.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _runAnalysis,
              icon: const Icon(Icons.analytics_outlined, color: Colors.white),
              label: const Text("Run Prediction Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryTeal),
          const SizedBox(height: 20),
          Text("Consulting medical guidelines...", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text("Predicting $_selectedTimeline trajectory...", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        // Header with Refresh
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
             Text("Analysis for: $_selectedTimeline ", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
             GestureDetector(
               onTap: _runAnalysis,
               child: Row(
                 children: [
                   Icon(Icons.refresh, size: 14, color: primaryTeal),
                   const SizedBox(width: 4),
                   Text("Refresh", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryTeal)),
                 ],
               ),
             )
          ],
        ),
        const SizedBox(height: 8),

        // Health Trajectory Graph
        _buildTrajectoryCard(),
        const SizedBox(height: 24),

        // Neuro-Somatic Impact
        _buildSectionHeader("NEURO-SOMATIC IMPACT"),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildImpactCard("Mood & Mind", _analysisData!.moodAnalysis, Icons.psychology, Colors.purple)),
            const SizedBox(width: 12),
            Expanded(child: _buildImpactCard("Physiology", _analysisData!.bodyAnalysis, Icons.favorite, Colors.orange)),
          ],
        ),
        const SizedBox(height: 24),

        // Nutrients
        _buildSectionHeader("NUTRIENTS OF CONCERN"),
        const SizedBox(height: 12),
        _buildNutrientList(),
        const SizedBox(height: 24),

        // Recommendation
        _buildRecommendationCard(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Health Prediction", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("Based on your inventory habits", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["3 months", "1 year", "5 years"].map((time) {
              bool isSelected = _selectedTimeline == time;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedTimeline = time);
                    // Automatically run analysis if data exists, otherwise wait for button press
                    if (_analysisData != null) {
                      _runAnalysis();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryTeal : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      time.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- TRAJECTORY CARD ---
  Widget _buildTrajectoryCard() {
    final score = _analysisData!.healthScore;
    final spots = [
      const FlSpot(0, 50),
      FlSpot(1, 50 + (score - 50) * 0.4),
      FlSpot(2, 50 + (score - 50) * 0.8),
      FlSpot(3, score.toDouble()),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PREDICTED SCORE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                  const SizedBox(height: 4),
                  Text("$score/100", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryTeal)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text("Trajectory", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0, maxX: 3, minY: 0, maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: primaryTeal,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: index == 3 ? 6 : 0, 
                          color: primaryTeal,
                          strokeWidth: 3,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryTeal.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _analysisData!.predictionSummary,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  // --- IMPACT CARDS ---
  Widget _buildImpactCard(String title, ImpactAnalysis data, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.state,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            data.mechanism,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
            maxLines: 3, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- NUTRIENT LIST ---
  Widget _buildNutrientList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: _analysisData!.keyNutrients.map((n) {
          Color statusColor;
          String status = n.status.toLowerCase();
          if (status.contains('excess') || status.contains('high') || status.contains('deficient')) {
            statusColor = Colors.red.shade400;
          } else if (status.contains('low')) {
            statusColor = Colors.orange.shade400;
          } else {
            statusColor = Colors.blue.shade400;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 4, height: 32,
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.nutrient, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(n.impact, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    n.status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryTeal, darkGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primaryTeal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("AI RECOMMENDATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _analysisData!.recommendation,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // --- HEALTH METRICS (BMI CARD) ---
  Widget _buildHealthMetricsCard() {
    double bmi = _calculateBMI();
    String bmiText = bmi > 0 ? bmi.toStringAsFixed(1) : "--";
    String status = "Unknown";
    Color statusColor = Colors.grey;

    if (bmi > 0) {
      if (bmi > 25) {
        status = "Overweight";
        statusColor = Colors.orange;
      } else if (bmi < 18.5) {
        status = "Underweight";
        statusColor = Colors.blue;
      } else {
        status = "Healthy";
        statusColor = Colors.green;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem("WEIGHT", "${_user?.weight ?? '--'} KG", Icons.monitor_weight_outlined),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              _buildMetricItem("HEIGHT", "${_user?.height ?? '--'} CM", Icons.height),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("BMI STATUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(status, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
              Text(bmiText, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTeal)),
            ],
          ),
          const SizedBox(height: 10),
          // Simple visual slider for BMI
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (bmi / 40).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade100,
              color: statusColor,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5));
  }
}