import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MinuteMatchApp());
}

class MinuteMatchApp extends StatelessWidget {
  const MinuteMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minute Match',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
