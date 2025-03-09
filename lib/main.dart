import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:megaeth_simulator/constants/theme.dart';
import 'package:megaeth_simulator/screens/simulator_screen.dart';
import 'package:megaeth_simulator/screens/learning_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MegaETH Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppTheme.primaryCyan,
          secondary: AppTheme.primaryPurple,
          background: AppTheme.darkBackground,
          surface: AppTheme.darkBackgroundLight,
        ),
        fontFamily: 'Helvetica', // Premium $1B+ Y2K inspired font
        textTheme: TextTheme(
          displayLarge: GoogleFonts.spaceGrotesk( // Premium Y2K-inspired font
            color: AppTheme.platinum,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
          displayMedium: GoogleFonts.spaceGrotesk(
            color: AppTheme.platinum,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
          displaySmall: GoogleFonts.spaceGrotesk(
            color: AppTheme.platinum,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
          headlineLarge: GoogleFonts.spaceGrotesk(
            color: AppTheme.platinum,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
          headlineMedium: GoogleFonts.spaceGrotesk(
            color: AppTheme.platinum,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
          headlineSmall: GoogleFonts.spaceGrotesk(
            color: AppTheme.platinum,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
          bodyLarge: TextStyle(
            color: AppTheme.silver,
            fontFamily: 'Helvetica',
          ),
          bodyMedium: TextStyle(
            color: AppTheme.silver,
            fontFamily: 'Helvetica',
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  final _pages = const [
    SimulatorScreen(),
    LearningScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppTheme.darkBackgroundLight,
        selectedItemColor: AppTheme.primaryCyan,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Simulator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}