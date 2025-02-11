import 'package:flutter/material.dart';

class GameView extends StatelessWidget {
  final Widget cardGame;

  const GameView({super.key, required this.cardGame});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: cardGame,
    );
  }
}
