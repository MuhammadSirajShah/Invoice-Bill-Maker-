import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const InvoiceBillMakerApp());
}

class InvoiceBillMakerApp extends StatelessWidget {
  const InvoiceBillMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Invoice & Bill Maker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const HomeScreen(),
    );
  }
}