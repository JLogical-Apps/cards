import 'package:flutter/material.dart';
import 'package:solitaire/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Cards',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            iconColor: Colors.black,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
        )),
    home: HomePage(),
  ));
}
