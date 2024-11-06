import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectDotsPage extends StatefulWidget {
  final String roomId;
  final String playerId;
  final String playerName;

  const ConnectDotsPage({
    Key? key,
    required this.roomId,
    required this.playerId,
    required this.playerName,
  }) : super(key: key);

  @override
  _ConnectDotsPageState createState() => _ConnectDotsPageState();
}

class _ConnectDotsPageState extends State<ConnectDotsPage> {
  late List<List<int>> verticalLines;
  late List<List<int>> horizontalLines;
  late Map<String, int> playerScores;
  late String currentPlayerId;
  late List<Map<String, String>> players;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();

    // Initialize lines with default values (0 means no line drawn)
    verticalLines = List.generate(4, (_) => List.filled(5, 0));
    horizontalLines = List.generate(5, (_) => List.filled(4, 0));
    playerScores = {};

    // Listen for Firestore changes in real-time
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          verticalLines = List<List<int>>.from(snapshot.data()?['verticalLines'] ?? verticalLines);
          horizontalLines = List<List<int>>.from(snapshot.data()?['horizontalLines'] ?? horizontalLines);
          currentPlayerId = snapshot.data()?['currentPlayerId'] ?? '';
          isGameOver = snapshot.data()?['isGameOver'] ?? false;
          players = List<Map<String, dynamic>>.from(snapshot.data()?['players'] ?? []).map((e) => Map<String, String>.from(e)).toList();
          playerScores = Map<String, int>.from(snapshot.data()?['playerScores'] ?? {});
        });
      }
    });
  }

  void handleTap(int row, int col, bool isHorizontal) async {
    if (currentPlayerId == widget.playerId) {
      // Update the Firestore document for the room
      final roomRef = FirebaseFirestore.instance.collection('rooms').doc(widget.roomId);

      // Determine which line (vertical or horizontal) to update
      if (isHorizontal && horizontalLines[row][col] == 0) {
        // Update horizontal line
        horizontalLines[row][col] = 1;
      } else if (!isHorizontal && verticalLines[row][col] == 0) {
        // Update vertical line
        verticalLines[row][col] = 1;
      } else {
        return; // Return if line already exists
      }

      await roomRef.update({
        'horizontalLines': horizontalLines,
        'verticalLines': verticalLines,
        'currentPlayerId': _getNextPlayerId(),
      });
    }
  }

  String _getNextPlayerId() {
    final currentIndex = players.indexWhere((player) => player['id'] == currentPlayerId);
    final nextIndex = (currentIndex + 1) % players.length;
    return players[nextIndex]['id'] ?? players[0]['id']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Connect the Dots'),
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          // Display current turn at the top
          if (!isGameOver)
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[800],
              child: Text(
                currentPlayerId == widget.playerId
                    ? 'Your Turn!'
                    : '${_getPlayerNameById(currentPlayerId)}\'s Turn',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: 5 * 5,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                ),
                itemBuilder: (context, index) {
                  int row = index ~/ 5;
                  int col = index % 5;

                  return GestureDetector(
                    onTap: () {
                      // Logic to check if tap is between adjacent dots
                      if (col < 4 && row < 5) handleTap(row, col, true);
                      if (row < 4 && col < 5) handleTap(row, col, false);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        border: Border.all(color: Colors.white54),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Display player names and scores at the bottom
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: players.map((player) {
                final color = _getPlayerColor(player['id'] ?? 'default_id');
                return Column(
                  children: [
                    Text(
                      player['name'] ?? '',
                      style: TextStyle(color: color, fontSize: 16),
                    ),
                    Text(
                      '${playerScores[player['id']] ?? 0}',
                      style: TextStyle(color: color, fontSize: 20),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlayerNameById(String playerId) {
    final player = players.firstWhere(
          (p) => p['id'] == playerId,
      orElse: () => {'name': 'Unknown Player'},
    );
    return player['name'] ?? 'Unknown Player';
  }

  Color _getPlayerColor(String playerId) {
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.orange];
    final playerIndex = players.indexWhere((player) => player['id'] == playerId);
    return colors[playerIndex % colors.length];
  }
}
