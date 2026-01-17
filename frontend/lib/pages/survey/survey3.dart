import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/auth_service.dart';
import 'package:frontend/pages/dashboard/dashboard.dart';


class Survey3 extends StatefulWidget {
  // All accumulated data
  final int height;
  final int weight;
  final String gender;
  final String goal;
  final List<String> dietaryPreferences;
  final List<String> selectedConditions;

  const Survey3({
    super.key, 
    required this.height, 
    required this.weight, 
    required this.gender,
    required this.goal,
    required this.dietaryPreferences,
    required this.selectedConditions,
  });

  @override
  State<Survey3> createState() => _Survey3State();
}

class _Survey3State extends State<Survey3> {
  final Color primaryTeal = const Color(0xFF29A38F);
  final Map<String, String> _details = {};
  bool _isLoading = false;

  Future<void> _submitAll() async {
    setState(() => _isLoading = true);

    // Combine all detail text fields into one string for the backend 
    // (since backend expects Optional[str] for health_details)
    String combinedDetails = "";
    _details.forEach((condition, detail) {
      if (detail.isNotEmpty) {
        combinedDetails += "$condition: $detail; ";
      }
    });

    final success = await AuthService().submitSurvey(
      height: widget.height,
      weight: widget.weight,
      gender: widget.gender,
      goal: widget.goal,
      dietaryPreferences: widget.dietaryPreferences,
      healthConditions: widget.selectedConditions,
      healthDetails: combinedDetails,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Step 4 of 4", style: TextStyle(color: Colors.black54, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(value: 0.9, color: Color(0xFF29A38F), backgroundColor: Color(0xFFE0E0E0)),
            const SizedBox(height: 32),
            const Text("Additional", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text("Health Details", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryTeal)),
            const SizedBox(height: 16),
            const Text("This helps our AI fine-tune your meal plans for your specific health needs.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            ...widget.selectedConditions.map((condition) => _buildDetailInput(condition)).toList(),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Complete Profile", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInput(String condition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: primaryTeal),
              const SizedBox(width: 8),
              Text(condition, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => _details[condition] = value,
            decoration: InputDecoration(
              hintText: "E.g., Years since diagnosis, current medication...",
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}