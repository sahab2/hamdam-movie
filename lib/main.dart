import 'package:flutter/material.dart';
import 'package:hamdam_movie/web_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: WebViewMobileScreen(),);
  }
}

