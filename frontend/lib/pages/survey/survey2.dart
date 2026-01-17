import 'package:flutter/material.dart';
import 'survey3.dart'; // Ensure this file exists for navigation

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Survey2(),
  ));
}

class Survey2 extends StatefulWidget {
  const Survey2({super.key});

  @override
  State<Survey2> createState() => _Survey2State();
}

class _Survey2State extends State<Survey2> {
  // Selection States
  String _selectedGoal = "Weight Loss"; 
  List<String> _selectedDiets = [];
  List<String> _selectedConditions = [];

  final Color primaryTeal = const Color(0xFF29A38F);

  @override
  Widget build(BuildContext context) {
    // Logic to determine if we move to Survey3 or Finish
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

            // 1. Goals Section
            _buildSectionTitle("What is your primary goal?"),
            const SizedBox(height: 12),
            _buildGoalSelector(),

            const SizedBox(height: 32),

            // 2. Dietary Preferences Section
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

            // 3. Health Conditions Section
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
                onPressed: () {
                  if (needsDetails) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Survey3(selectedConditions: _selectedConditions),
                      ),
                    );
                  } else {
                    print("Survey Finished. Selected Conditions: $_selectedConditions");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
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