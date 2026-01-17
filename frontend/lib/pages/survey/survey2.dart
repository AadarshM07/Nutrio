import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/auth_service.dart';
import 'package:frontend/pages/dashboard/dashboard.dart';
import 'survey3.dart';

class Survey2 extends StatefulWidget {
  // Received from previous step
  final int height;
  final int weight;
  final String gender;

  const Survey2({
    super.key, 
    required this.height, 
    required this.weight, 
    required this.gender
  });

  @override
  State<Survey2> createState() => _Survey2State();
}

class _Survey2State extends State<Survey2> {
  String _selectedGoal = "Weight Loss"; 
  List<String> _selectedDiets = [];
  List<String> _selectedConditions = [];
  bool _isLoading = false;

  final Color primaryTeal = const Color(0xFF29A38F);

  Future<void> _handleFinish() async {
    setState(() => _isLoading = true);
    
    // Submit Data immediately if no complex conditions
    final success = await AuthService().submitSurvey(
      height: widget.height,
      weight: widget.weight,
      gender: widget.gender,
      goal: _selectedGoal,
      dietaryPreferences: _selectedDiets,
      healthConditions: ["None"], // Explicitly none
      healthDetails: "",
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Navigate to Dashboard and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool needsDetails = _selectedConditions.isNotEmpty && 
                        !_selectedConditions.contains("None");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Step 3 of 4", style: TextStyle(color: Colors.black54, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(value: 0.75, color: Color(0xFF29A38F), backgroundColor: Color(0xFFE0E0E0)),
            const SizedBox(height: 32),
            const Text("Optimize your", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text("lifestyle", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTeal)),
            const SizedBox(height: 16),
            const Text("Personalize your experience to match your busy schedule and health needs.", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 32),

            _buildSectionTitle("What is your primary goal?"),
            const SizedBox(height: 12),
            _buildGoalSelector(),

            const SizedBox(height: 32),
            _buildSectionTitle("Dietary Preferences"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildMultiSelectChip("Vegetarian", _selectedDiets),
                _buildMultiSelectChip("Vegan", _selectedDiets),
                _buildMultiSelectChip("Keto", _selectedDiets),
                _buildMultiSelectChip("High Protein", _selectedDiets),
                _buildMultiSelectChip("Lactose Free", _selectedDiets),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionTitle("Health Conditions (Optional)"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildHealthChip("Diabetes"),
                _buildHealthChip("Cholestrol"),
                _buildHealthChip("PCOS"),
                _buildHealthChip("None"),
              ],
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (needsDetails) {
                    // Pass ALL accumulated data to Step 4
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Survey3(
                          height: widget.height,
                          weight: widget.weight,
                          gender: widget.gender,
                          goal: _selectedGoal,
                          dietaryPreferences: _selectedDiets,
                          selectedConditions: _selectedConditions,
                        ),
                      ),
                    );
                  } else {
                    _handleFinish();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      needsDetails ? "Continue →" : "Finish survey →",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Helper widgets _buildSectionTitle, _buildHealthChip, etc. remain the same)
  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildHealthChip(String label) {
    bool isSelected = _selectedConditions.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (label == "None") {
            _selectedConditions = selected ? ["None"] : [];
          } else {
            _selectedConditions.remove("None");
            if (selected) {
              _selectedConditions.add(label);
            } else {
              _selectedConditions.remove(label);
            }
          }
        });
      },
      selectedColor: primaryTeal.withOpacity(0.2),
      checkmarkColor: primaryTeal,
      backgroundColor: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? primaryTeal : Colors.grey[200]!),
      ),
    );
  }

  Widget _buildMultiSelectChip(String label, List<String> list) {
    bool isSelected = list.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            list.add(label);
          } else {
            list.remove(label);
          }
        });
      },
      selectedColor: primaryTeal.withOpacity(0.2),
      checkmarkColor: primaryTeal,
      backgroundColor: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? primaryTeal : Colors.grey[200]!),
      ),
    );
  }

  Widget _buildGoalSelector() {
    List<String> goals = ["Weight Loss", "Maintain", "Muscle Gain"];
    return Row(
      children: goals.map((goal) {
        bool isSelected = _selectedGoal == goal;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGoal = goal),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? primaryTeal : Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isSelected ? primaryTeal : Colors.grey[200]!),
              ),
              child: Center(
                child: Text(
                  goal,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}