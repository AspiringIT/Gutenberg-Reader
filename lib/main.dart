import 'package:flutter/material.dart';
import 'package:gutenberg_reader/app/Theme.dart';
import 'package:gutenberg_reader/screens/Home_Screen.dart';
import 'package:gutenberg_reader/screens/Landing_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showLanding = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenLanding = prefs.getBool('has_seen_landing') ?? false;

    // Set to true to always show landing, or false to show only on first launch
    setState(() {
      _showLanding = true; //!hasSeenLanding;
    });

    // Mark as seen
    await prefs.setBool('has_seen_landing', true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gutenberg Reader',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: _showLanding ? const LandingScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}