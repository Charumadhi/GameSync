import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'tictactoepage.dart';

class GameOptionsPage extends StatefulWidget {
  final String playerId;
  final String playerName;
  final String selectedGame; // The selected game passed from the previous page

  GameOptionsPage({
    required this.playerId,
    required this.playerName,
    required this.selectedGame,
  });

  @override
  _GameOptionsPageState createState() => _GameOptionsPageState();
}

class _GameOptionsPageState extends State<GameOptionsPage> {
  bool isCreatingGame = false;
  bool isJoiningGame = false;
  String passkey = '';
  TextEditingController passkeyController = TextEditingController();
  String opponentName = ''; // Placeholder for opponent's name

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
    await FirebaseFirestore.instance.collection('rooms').doc(passkey).set({
      'gameId': gameId,
      'passkey': passkey,
      'hostPlayerId': widget.playerId,
      'hostPlayerName': widget.playerName,
      'players': [
        {'playerId': widget.playerId, 'playerName': widget.playerName},
      ],
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
      'startedAt': null,
    });
  }

  // Function to join an existing room in Firestore
  Future<void> joinRoomInFirestore(String enteredPasskey) async {
    DocumentReference roomRef = FirebaseFirestore.instance.collection('rooms').doc(enteredPasskey);
    DocumentSnapshot roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      // Get opponent's name
      var players = roomSnapshot['players'];
      setState(() {
        opponentName = players[0]['playerName']; // Assuming the first player is the host (opponent)
      });

      // Update players array to include the current player
      await roomRef.update({
        'players': FieldValue.arrayUnion([
          {'playerId': widget.playerId, 'playerName': widget.playerName}
        ]),
      });

      // Navigate to TicTacToePage with opponentName
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicTacToePage(
            roomId: enteredPasskey,
            playerId: widget.playerId,
            playerName: widget.playerName,
            //opponentName: opponentName, // Pass the opponent's name
          ),
        ),
      );
    } else {
      // Handle invalid passkey
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid passkey. Room not found.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Game Option'),
        backgroundColor: Colors.white70, // Updated AppBar color
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.jpg'), // Placeholder image path
            fit: BoxFit.cover,
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isCreatingGame = true;
                      isJoiningGame = false;
                      passkey = generatePasskey(); // Generate passkey when creating game
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
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
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text('Join a Game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isCreatingGame) ...[
              Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Share the passkey',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => copyToClipboard(passkey),
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
                  // Create the room in Firestore and navigate to TicTacToePage
                  await createRoomInFirestore(widget.selectedGame, passkey);

                  // Navigate to TicTacToePage after creating room
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicTacToePage(
                        roomId: passkey,
                        playerId: widget.playerId,
                        playerName: widget.playerName,
                        //opponentName: '', // No opponent yet when creating the game
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text('Start Game', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ] else if (isJoiningGame) ...[
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
                  // Attempt to join the game
                  joinRoomInFirestore(enteredPasskey);
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
