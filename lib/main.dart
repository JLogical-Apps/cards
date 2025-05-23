import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solitaire/home_page.dart';
import 'package:solitaire/licenses.dart';
import 'package:solitaire/styles/playing_card_asset_bundle_cache.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerExtraLicenses();
  await PlayingCardAssetBundleCache.preloadAssets();

  runApp(ProviderScope(
    child: MaterialApp(
      title: 'Cards',
      scaffoldMessengerKey: scaffoldMessengerKey,
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
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
        ),
        listTileTheme: ListTileThemeData(
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
      home: HomePage(),
    ),
  ));
}
