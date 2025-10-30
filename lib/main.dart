import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math';
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HangmanGame(),
  ));
}

Widget gameTitle() {
  return BounceInDown(
    duration: const Duration(seconds: 2),
    child: ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF00FFFF), Color(0xFF00FF88), Color(0xFF00FFA5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        "GUESS THE WORD",
        textAlign: TextAlign.center,
        style: GoogleFonts.orbitron(
          textStyle: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: Colors.white, // this will be masked by shader
            shadows: [
              Shadow(
                blurRadius: 20,
                color: Colors.tealAccent,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
class HangmanGame extends StatefulWidget {
  const HangmanGame({super.key});

  @override
  State<HangmanGame> createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  final List<String> _words = [
    "HAPPY",
    "REFLECT",
    "PROGRAM",
    "DART",
    "FLUTTER",
    "MOBILE",
    "WIDGET",
    "BUTTON",
    "SCREEN",
    "STATE",
  ];

  late String _wordToGuess;
  List<String> _guessedLetters = [];
  int _wrongGuesses = 0;
  final int _maxWrong = 6;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    final random = Random();
    _wordToGuess = _words[random.nextInt(_words.length)];
    _guessedLetters.clear();
    _wrongGuesses = 0;
    _gameOver = false;
    setState(() {});
  }

  void _showResultPopup(String title, bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ScaleTransitionPopup(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurpleAccent, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  won ? Icons.emoji_events_rounded : Icons.cancel_rounded,
                  color:
                      won ? Colors.greenAccent : Colors.redAccent.withOpacity(0.9),
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: won ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "The word was: $_wordToGuess",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _startNewGame();
                  },
                  child: const Text(
                    "Play Again",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _guessLetter(String letter) {
    if (_gameOver || _guessedLetters.contains(letter)) return;

    setState(() {
      _guessedLetters.add(letter);

      if (!_wordToGuess.contains(letter)) {
        _wrongGuesses++;
      }

      if (_wrongGuesses >= _maxWrong) {
        _gameOver = true;
        _showResultPopup("You Lost 😢", false);
      } else if (_wordToGuess
          .split('')
          .every((char) => _guessedLetters.contains(char))) {
        _gameOver = true;
        _showResultPopup("You Won 🎉", true);
      }
    });
  }

  String _getDisplayedWord() {
    return _wordToGuess
        .split('')
        .map((char) => _guessedLetters.contains(char) ? char : "_")
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guess The Word',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.grey.shade900,
              Colors.deepPurple.shade900.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Display Word
            Column(
              children: [
                Text(
                  'Wrong guesses: $_wrongGuesses / $_maxWrong',
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 25),
                Text(
                  _getDisplayedWord(),
                  style: const TextStyle(
                    fontSize: 40,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Guessed: ${_guessedLetters.join(", ")}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),

            // Keyboard Layout (fixed position)
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final rows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM',
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((letter) {
              final isGuessed = _guessedLetters.contains(letter);
              final isWrong = isGuessed && !_wordToGuess.contains(letter);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: isGuessed ? null : () => _guessLetter(letter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 45,
                    height: 55,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isGuessed
                          ? (isWrong
                              ? Colors.redAccent.withOpacity(0.8)
                              : Colors.greenAccent.withOpacity(0.8))
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

/// A smooth scale-in popup animation
class ScaleTransitionPopup extends StatefulWidget {
  final Widget child;
  const ScaleTransitionPopup({super.key, required this.child});

  @override
  State<ScaleTransitionPopup> createState() => _ScaleTransitionPopupState();
}

class _ScaleTransitionPopupState extends State<ScaleTransitionPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
