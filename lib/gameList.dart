import 'package:flutter/material.dart';
import 'gameOptions.dart'; // Import the GameOptionsPage

class GamesListPage extends StatelessWidget {
  final String playerId;
  final String displayName;

  // Constructor to receive playerId and displayName
  GamesListPage({Key? key, required this.playerId, required this.displayName}) : super(key: key);

  // Dummy list of games
  final List<Map<String, String>> games = [
    {'name': 'Tic-Tac-Toe', 'image': 'assets/tictactoe.jpeg'},
    {'name': 'Dots and boxes', 'image': 'assets/dotsAndPages.png'},
    {'name': 'Match the Cards', 'image': 'assets/matchTheCards.jpg'},
    {'name': 'Find the Joker', 'image': 'assets/findTheJoker.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games List'),
        backgroundColor: Colors.white70, // Changed to a solid color for better visibility
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/back.jpg', // Add your background image here
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),
          // Content of the game list
          Padding(
            padding: const EdgeInsets.all(16.0), // Add some padding around the grid
            child: Column(
              children: [
                const SizedBox(height: 50), // Space between the AppBar and content

                // Display playerId and displayName in a styled box
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Semi-transparent background
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Player ID: $playerId',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent, // Change color as needed
                        ),
                      ),
                      const SizedBox(height: 8), // Spacing between player ID and name
                      Text(
                        'Name: $displayName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87, // Change color as needed
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Space between text and the grid

                // Instruction text
                const Text(
                  'Please select a game to play!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.white, // Change color as needed
                  ),
                ),
                const SizedBox(height: 20), // Space before the grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 items per row
                      mainAxisSpacing: 20.0, // Spacing between rows
                      crossAxisSpacing: 15.0, // Spacing between columns
                      childAspectRatio: 0.7, // Adjust ratio for better appearance
                    ),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      return _buildGameCard(context, games[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build each game card
  Widget _buildGameCard(BuildContext context, Map<String, String> game) {
    return GestureDetector(
      onTap: () {
        // Navigate to GameOptionsPage with playerId, displayName, and selected game
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameOptionsPage(
              playerId: playerId,
              playerName: displayName,
              selectedGame: game['name']!, // Passing the selected game name
            ),
          ),
        );
      },
      child: Card(
        elevation: 4, // Shadow for the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Expanded(
              // Game image
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)), // Rounded top corners
                child: Image.asset(
                  game['image']!, // Path to game image
                  height: 100, // Set a fixed height
                  width: 175, // Set a fixed width
                  fit: BoxFit.cover, // Scale to cover available space
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Game name
            Padding(
              padding: const EdgeInsets.all(8.0), // Add padding around the text
              child: Text(
                game['name']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // You can change the color if needed
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
