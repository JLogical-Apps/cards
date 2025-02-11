import 'package:solitaire/game_view.dart';
import 'package:solitaire/games/golf_solitaire.dart';
import 'package:solitaire/games/solitaire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(MaterialApp(
    title: 'Cards',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
    ),
    home: HomePage(),
  ));
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final games = {
      'Golf Solitaire': GolfSolitaire(),
      'Solitaire': Solitaire(),
    };
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: games.entries.map(
              (entry) {
                return ListTile(
                  title: Text(entry.key),
                  onTap: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameView(cardGame: entry.value))),
                  trailing: Icon(Icons.chevron_right),
                );
              },
            ).toList(),
          ).toList(),
        ),
      ),
    );
  }
}
