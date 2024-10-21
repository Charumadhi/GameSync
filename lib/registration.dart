import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'dart:math'; // Add this for random number generation
import 'gameList.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  DateTime? selectedDate;
  String? skillLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background (same as login page)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.blueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title Text
                    const Text(
                      "Register for GameSync",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black45,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Full Name Field
                    _buildTextField(
                      controller: fullNameController,
                      label: 'Full Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    _buildTextField(
                      controller: emailController,
                      label: 'Email Address',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    _buildTextField(
                      controller: passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Display Name Field
                    _buildTextField(
                      controller: displayNameController,
                      label: 'Display Name',
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: 20),

                    // Date of Birth Picker
                    GestureDetector(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black45.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          selectedDate == null
                              ? 'Select Date'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Skill Level Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Skill Level',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black45.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: <String>['Beginner', 'Intermediate', 'Expert']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          skillLevel = value;
                        });
                      },
                    ),
                    const SizedBox(height: 40),

                    // Register Button with gradient
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.purpleAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black87.withOpacity(0.5),
                              blurRadius: 8.0,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Text Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black45.withOpacity(0.5),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Method to create account (same as before)
  void _createAccount() async {
    if (fullNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        displayNameController.text.isNotEmpty &&
        selectedDate != null &&
        skillLevel != null) {

      // Check if email or full name already exists
      final QuerySnapshot emailQuery = await FirebaseFirestore.instance
          .collection('players')
          .where('email', isEqualTo: emailController.text)
          .get();

      final QuerySnapshot nameQuery = await FirebaseFirestore.instance
          .collection('players')
          .where('full_name', isEqualTo: fullNameController.text)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        // Show error if email already exists
        _showErrorDialog('This email address is already associated with an account.');
        return;
      }

      if (nameQuery.docs.isNotEmpty) {
        // Show error if full name already exists
        _showErrorDialog('User already exists!');
        return;
      }

      // Generate a random 6-digit player_id
      String playerId = (Random().nextInt(900000) + 100000).toString();

      // Create the user in Firestore
      await FirebaseFirestore.instance.collection('players').add({
        'full_name': fullNameController.text,
        'email': emailController.text,
        'display_name': displayNameController.text,
        'date_of_birth': selectedDate.toString(),
        'skill_level': skillLevel,
        'player_id': playerId, // Store player_id
        'password': passwordController.text,
      });

      _showSuccessDialog(context, playerId, displayNameController.text); // Show success dialog
    } else {
      // Show error if any fields are missing
      _showErrorDialog('Please fill in all fields!');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Error!',
            style: TextStyle(color: Colors.red, fontSize: 22),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog only
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String playerId, String displayName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Success!',
            style: TextStyle(color: Colors.green, fontSize: 22),
          ),
          content: const Text(
            'Account Created Successfully!',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to GamesListPage with playerId and displayName
                Navigator.of(context).pop(); // Close the dialog first
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GamesListPage(
                      playerId: playerId,
                      displayName: displayName,
                    ),
                  ),
                );
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }
}


