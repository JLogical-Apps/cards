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
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
        canvasColor: Colors.transparent,
        chipTheme: ChipThemeData(
          color: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.black
                : states.contains(WidgetState.disabled)
                    ? Colors.black12
                    : Color(0xFF666666),
          ),
          showCheckmark: false,
          labelStyle: TextStyle(color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none,
        ),
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
