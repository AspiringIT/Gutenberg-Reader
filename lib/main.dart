import 'package:flutter/material.dart';
import 'package:gutenberg_reader/app/Theme.dart';
import 'package:gutenberg_reader/screens/Home_Screen.dart';
import 'package:gutenberg_reader/screens/Landing_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

    setState(() {
      _showLanding = true; // set false if you want only first launch
    });

    await prefs.setBool('has_seen_landing', true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Gutenberg Reader',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: _showLanding ? const LandingScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
