import 'package:evostream/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

GlobalKey<NavigatorState> nKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvoStream',

      navigatorKey: nKey,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData(
        fontFamily: 'Poppins',
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          year2023: false,
        ),
      ),
    );
  }
}
