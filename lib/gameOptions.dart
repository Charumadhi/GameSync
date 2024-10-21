import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart'; // For clipboard

class GameOptionsPage extends StatefulWidget {
  final String playerId;
  final String playerName;
  final String selectedGame; // The selected game passed from the previous page

  GameOptionsPage({required this.playerId, required this.playerName, required this.selectedGame});

  @override
  _GameOptionsPageState createState() => _GameOptionsPageState();
}

class _GameOptionsPageState extends State<GameOptionsPage> {
  bool isCreatingGame = false;
  bool isJoiningGame = false;
  String passkey = '';
  TextEditingController passkeyController = TextEditingController();

  // Function to generate random 6-character passkey
  String generatePasskey() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  // Function to copy passkey to clipboard
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Passkey copied to clipboard!')),
    );
  }

  // Function to create a room in Firestore
  Future<void> createRoomInFirestore(String gameId, String passkey) async {
    await FirebaseFirestore.instance.collection('rooms').add({
      'gameId': gameId, // Reference to the game
      'passkey': passkey, // Unique passkey
      'hostPlayerId': widget.playerId, // Host's ID
      'hostPlayerName': widget.playerName, // Host's name
      'players': [
        {'playerId': widget.playerId, 'playerName': widget.playerName}, // Add host as the first player
      ],
      'status': 'waiting', // Game is waiting for players
      'createdAt': FieldValue.serverTimestamp(), // Timestamp of room creation
      'startedAt': null, // Game hasn't started yet
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Game Option'),
        backgroundColor: Colors.white70, // Updated AppBar color
      ),
      body: Container(
        // Add background image here
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.jpg'), // Placeholder image path
            fit: BoxFit.cover, // Ensures the image covers the entire screen
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 30,
              mainAxisSpacing: 20,
              children: [
                // Create Game button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isCreatingGame = true;
                      isJoiningGame = false;
                      passkey = generatePasskey(); // Generate passkey when creating game
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo, // Button color
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Square with rounded corners
                    ),
                    elevation: 5, // Shadow
                  ),
                  child: Text('Create Game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isJoiningGame = true;
                      isCreatingGame = false;
                      passkeyController.clear(); // Clear the passkey controller
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo, // Button color
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Square with rounded corners
                    ),
                    elevation: 5,
                  ),
                  child: Text('Join a Game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isCreatingGame) ...[
              // Card with shadow for passkey
              Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Share the passkey',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => copyToClipboard(passkey), // Copy button
                      ),
                      labelStyle: TextStyle(color: Colors.black87),
                    ),
                    controller: TextEditingController(text: passkey),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Create the room in Firestore and navigate to game screen
                  await createRoomInFirestore(widget.selectedGame, passkey);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        playerId: widget.playerId,
                        playerName: widget.playerName,
                        passkey: passkey,
                        isCreator: true, // Indicating player is the creator
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button color
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded rectangle
                  ),
                  elevation: 5,
                ),
                child: const Text('Start Game', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ] else if (isJoiningGame) ...[
              // Joining the game
              Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: passkeyController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Passkey',
                      labelStyle: TextStyle(color: Colors.black87),
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String enteredPasskey = passkeyController.text;
                  // Navigate to the game screen as the joiner
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        playerId: widget.playerId,
                        playerName: widget.playerName,
                        passkey: enteredPasskey,
                        isCreator: false, // Indicating player is joining the game
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text('Join Game', style: TextStyle(fontSize: 18)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Game screen after creating/joining
class GameScreen extends StatelessWidget {
  final String playerId;
  final String playerName;
  final String passkey;
  final bool isCreator;

  GameScreen({
    required this.playerId,
    required this.playerName,
    required this.passkey,
    required this.isCreator,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Screen'),
      ),
      body: Center(
        child: Text(
          '${isCreator ? "Creator" : "Joiner"}: $playerName with Passkey: $passkey',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
