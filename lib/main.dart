import 'package:flutter/material.dart';
import 'login.dart';
import 'registration.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const GameSyncApp());
}

class GameSyncApp extends StatelessWidget {
  const GameSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background_image.jpg', // Replace with your background image
              fit: BoxFit.cover,
            ),
          ),
          // Content on top of background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App logo in the center
                // App logo in the center with some downward shift
                Transform.translate(
                  offset: const Offset(0, 90), // Move the logo 50 pixels down
                  child: Image.asset(
                    'assets/logo.png', // Replace with your logo image
                    height: 200,
                    width: 200,
                  ),
                ),
                const SizedBox(height: 65),
                // App name in the center
                const Text(
                  'GameSync',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 60),
                // Moving the GameSync text slightly up
                const SizedBox(height: 100), // Adding space above the GameSync text
                // Login button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Login Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
                // New user prompt with registration page navigation
                GestureDetector(
                  onTap: () {
                    // Navigate to Registration Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationPage()),
                    );
                  },
                  child: const Text(
                    'New user? Create an account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline, // Add underline to indicate a link
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
