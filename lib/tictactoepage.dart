import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'gameList.dart';

class TicTacToePage extends StatefulWidget {
  final String roomId;
  final String playerId;
  final String playerName;

  TicTacToePage({
    required this.roomId,
    required this.playerId,
    required this.playerName,
  });

  @override
  _TicTacToePageState createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  late List<String> board;
  String currentPlayer = 'X';
  bool isGameOver = false;
  String winner = '';
  String opponentName = '';

  @override
  void initState() {
    super.initState();
    board = List.filled(9, '');

    // Set up Firestore listener for real-time game updates
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          board = List<String>.from(snapshot.data()?['board'] ?? List.filled(9, ''));
          currentPlayer = snapshot.data()?['currentPlayer'] ?? 'X';
          isGameOver = snapshot.data()?['isGameOver'] ?? false;
          winner = snapshot.data()?['winner'] ?? '';

          // Fetch opponent name from Firestore and update it in real time
          if (snapshot.data()?['players'] != null && snapshot.data()?['players'].length > 1) {
            opponentName = snapshot.data()?['players'][1]['playerName'] ?? 'Opponent';
            // Print the fetched name in the Android Studio terminal
            debugPrint('Opponent joined: $opponentName');
          } else {
            opponentName = 'Waiting...';
          }
        });

        // Start timestamp and status update when both players are in the room
        if (snapshot.data()?['players'].length == 2 && snapshot.data()?['status'] == 'waiting') {
          FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).update({
            'startedAt': FieldValue.serverTimestamp(),
            'status': 'playing',
          });
        }

        // Show winner dialog if the game is over
        if (isGameOver) {
          Future.delayed(Duration.zero, () => showWinnerDialog());
        }
      }
    });
  }

  Future<void> updateBoard(int index) async {
    if (isGameOver || board[index].isNotEmpty) return;

    board[index] = currentPlayer;
    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';

    await FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).update({
      'board': board,
      'currentPlayer': currentPlayer,
      'isGameOver': checkGameOver(),
      'winner': winner,
    });
  }

  bool checkGameOver() {
    List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combo in winningCombinations) {
      if (board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]] &&
          board[combo[0]].isNotEmpty) {
        winner = board[combo[0]] == 'X' ? widget.playerName : opponentName;
        return true;
      }
    }

    if (!board.contains('')) {
      winner = 'Draw';
      return true;
    }

    return false;
  }

  void resetGame() async {
    board = List.filled(9, '');
    currentPlayer = 'X';
    isGameOver = false;
    winner = '';

    await FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).update({
      'board': board,
      'currentPlayer': currentPlayer,
      'isGameOver': false,
      'winner': '',
    });
  }

  void showWinnerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(winner == 'Draw' ? 'It\'s a Draw!' : '$winner Wins!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Would you like to play again?'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  resetGame();
                  Navigator.pop(context);
                },
                child: Text('Play Again'),
              ),
              SizedBox(height: 10),
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac-Toe'),
        backgroundColor: Colors.white70,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Navigate to GamesListPage when the icon is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GamesListPage(
                    playerId: widget.playerId,
                    displayName: widget.playerName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      opponentName,  // Always display host name on the left
                      style: TextStyle(
                        fontSize: 20,
                        color: currentPlayer == 'X' ? Colors.blue : Colors.white,
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 50,
                      color: currentPlayer == 'X' ? Colors.blue : Colors.transparent,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      widget.playerName,  // Always display joiner name on the right
                      style: TextStyle(
                        fontSize: 20,
                        color: currentPlayer == 'O' ? Colors.red : Colors.white,
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 50,
                      color: currentPlayer == 'O' ? Colors.red : Colors.transparent,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => updateBoard(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: TextStyle(
                          fontSize: 48,
                          color: board[index] == 'X' ? Colors.blue : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


