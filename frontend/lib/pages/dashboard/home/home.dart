import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:frontend/pages/dashboard/home/dashboard_model.dart';
import 'package:frontend/pages/dashboard/home/dashboard_service.dart';


class HomePage extends StatefulWidget {
  final VoidCallback? onChatTapped;
  const HomePage({super.key, this.onChatTapped});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DashboardData? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DashboardService().fetchDashboardStats();
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    // Fallback if API fails or returns null
    final displayData = _data ?? DashboardData(
      healthBreakdown: [
        GraphDataPoint(label: "No Data", value: 100, color: Colors.grey.shade300)
      ],
      macroDistribution: [],
      aiFeedback: "Could not load insights. Please check your connection or add items to your inventory.",
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAINutritionist(),
          const SizedBox(height: 24),
          _buildHealthInsights(displayData),
          const SizedBox(height: 24),
          _buildAIRecommendation(displayData.aiFeedback),
          const SizedBox(height: 24),
          // _buildDailyEnergy(), // Optional: Keep or remove based on preference
        ],
      ),
    );
  }

  Widget _buildAINutritionist() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ask Your AI Nutritionist',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"Is this pasta healthy for my diabetes?"',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: widget.onChatTapped,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Chat Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsights(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Health Analysis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              // 1. Pie Chart Row
              Row(
                children: [
                  // Chart
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CustomPaint(
                      painter: DynamicDonutPainter(data.healthBreakdown),
                      child: const Center(
                        child: Text(
                          "Pantry\nScore",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.healthBreakdown.map((point) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildLegendItem(
                            "${point.label} (${point.value.toInt()}%)", 
                            point.color
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // 2. Macros Row (Bar indicators)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Est. Macro Distribution",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: data.macroDistribution.map((macro) {
                  return _buildMacroColumn(macro);
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroColumn(GraphDataPoint macro) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 8,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              width: 8,
              height: (60 * (macro.value / 100)).clamp(0, 60), // Simple scaling
              decoration: BoxDecoration(
                color: macro.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          macro.label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          "${macro.value.toInt()}%",
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAIRecommendation(String feedback) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light Green BG
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Dynamic Painter for the Donut Chart ---
class DynamicDonutPainter extends CustomPainter {
  final List<GraphDataPoint> data;

  DynamicDonutPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    double startAngle = -math.pi / 2; // Start from top

    // Calculate total value to normalize percentages if they don't add up to 100
    double total = data.fold(0, (sum, item) => sum + item.value);
    if (total == 0) total = 1;

    for (var item in data) {
      final sweepAngle = (item.value / total) * 2 * math.pi;
      
      paint.color = item.color;
      
      // Draw arc with a small gap for visual separation
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 0.05, // Small gap start
        sweepAngle - 0.05, // Small gap end
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}