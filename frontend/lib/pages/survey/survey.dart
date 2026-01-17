import 'package:flutter/material.dart';
import 'survey2.dart';

class Survey extends StatefulWidget {
  const Survey({super.key});

  @override
  State<Survey> createState() => _SurveyState();
}

class _SurveyState extends State<Survey> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  String _selectedGender = ""; 
  double? _bmi;
  String _category = "";

  void _calculateBMI() {
    final double? height = double.tryParse(_heightController.text);
    final double? weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);

      String category;
      if (bmi < 18.5) {category = "Underweight";}
      else if (bmi < 24.9) {category = "Normal weight";}
      else if (bmi < 29.9) {category = "Overweight";}
      else {category = "Obesity";}

      setState(() {
        _bmi = bmi;
        _category = category;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Step 2 of 4", style: TextStyle(color: Colors.black54, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Don't allow going back to signup easily
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(value: 0.5, color: Color(0xFF29A38F), backgroundColor: Color(0xFFE0E0E0)),
            const SizedBox(height: 32),
            const Text("Tell us about", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("yourself", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF29A38F))),
            const SizedBox(height: 16),
            const Text("Our AI uses your physical metrics to calibrate your daily caloric needs.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
        
            Row(
              children: [
                Expanded(child: _buildInputCard("Height", "cm", _heightController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputCard("Weight", "kg", _weightController)),
              ],
            ),
            
            const SizedBox(height: 32),
            const Text("Gender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                _genderChip("Male"),
                _genderChip("Female"),
                _genderChip("Other"),
              ],
            ),
            
            const SizedBox(height: 32),
            
            if (_bmi != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF29A38F)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Your BMI is ${_bmi!.toStringAsFixed(1)} ($_category).",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _calculateBMI(); 
                  if (_heightController.text.isNotEmpty && 
                      _weightController.text.isNotEmpty && 
                      _selectedGender.isNotEmpty) {
                    
                    // PASS DATA TO NEXT PAGE
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Survey2(
                          height: int.parse(_heightController.text),
                          weight: int.parse(_weightController.text),
                          gender: _selectedGender,
                        ), 
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill in all details")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29A38F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Continue →", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderChip(String label) {
    bool isSelected = _selectedGender == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedGender = selected ? label : "";
        });
      },
      selectedColor: const Color(0xFF29A38F).withOpacity(0.2),
      checkmarkColor: const Color(0xFF29A38F),
      backgroundColor: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? const Color(0xFF29A38F) : Colors.grey[200]!),
      ),
    );
  }

  Widget _buildInputCard(String label, String unit, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixText: unit,
              border: InputBorder.none,
              hintText: "0",
            ),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}