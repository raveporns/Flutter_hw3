import 'package:flutter/material.dart';
import 'package:homework3/product/product_main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '650710714',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 132, 255, 0)),
        useMaterial3: true,
      ),
      home: const ProductMainPage(),
    );
  }
}
