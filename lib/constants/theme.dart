import 'package:flutter/material.dart';

class AppTheme {
  // Sophisticated monochromatic Y2K-inspired $1B+ palette
  static const Color silver = Color(0xFFCBCBD4); // Core silver accent - flagship color
  static const Color platinum = Color(0xFFE5E5E5); // Ultra premium white
  static const Color jetBlack = Color(0xFF0A0A0A); // Deep premium black
  static const Color obsidian = Color(0xFF111116); // Richer dark background
  static const Color charcoal = Color(0xFF1D1D21); // Subtle dark accent
  static const Color steelGray = Color(0xFF808088); // Secondary accent
  static const Color chromium = Color(0xFFA8A8B2); // Tertiary accent
  static const Color iceWhite = Color(0xFFF9F9FF); // Glacial white accent
  static const Color errorRed = Color(0xFFB3B3B3); // Muted red in grayscale for errors
  
  // Maintain compatibility with existing code using monochromatic palette
  static const Color primaryPurple = silver; // Replace purple with premium silver
  static const Color primaryCyan = platinum; // Replace cyan with bright platinum
  static const Color accentGold = chromium; // Replace gold with chromium accent
  static const Color accentBlue = steelGray; // Replace blue with steel gray
  static const Color positiveGreen = silver; // Replace green with silver
  static const Color negativeRed = errorRed; // Replace red with grayscale error tone
  static const Color accentGlitch = iceWhite; // Keep white for glitch effects
  static const Color darkBackground = jetBlack; // Deeper premium black
  static const Color darkBackgroundLight = charcoal; // Rich dark accent
  
  // Sleek monochromatic Y2K-inspired gradients
  static final LinearGradient silverGradient = LinearGradient(
    colors: [silver, chromium.withOpacity(0.8), steelGray],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Maintain gradient compatibility
  static final LinearGradient purpleToCyanGradient = silverGradient;
  static final LinearGradient brownToGrayGradient = silverGradient;
  
  static final LinearGradient darkGradient = LinearGradient(
    colors: [jetBlack, obsidian, charcoal.withOpacity(0.9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static final LinearGradient glassGradient = LinearGradient(
    colors: [platinum.withOpacity(0.07), platinum.withOpacity(0.03)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static final LinearGradient beigeGradient = LinearGradient(
    colors: [silver, chromium],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static final LinearGradient earthGradient = LinearGradient(
    colors: [silver, steelGray, chromium],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Y2K-inspired sharp contrast gradient
  static final LinearGradient y2kGradient = LinearGradient(
    colors: [jetBlack, silver.withOpacity(0.9), jetBlack],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );
  
  // Y2K metallic gradient
  static final LinearGradient metallicGradient = LinearGradient(
    colors: [steelGray.withOpacity(0.7), silver, chromium.withOpacity(0.8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Elegant Y2K-inspired text styles with premium flair
  static final TextStyle headingStyle = TextStyle(
    fontFamily: 'Helvetica',
    color: iceWhite,
    fontWeight: FontWeight.bold,
    fontSize: 28,
    letterSpacing: 1.5,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 4,
        offset: Offset(1, 1),
      ),
    ],
  );
  
  static final TextStyle subHeadingStyle = TextStyle(
    fontFamily: 'Helvetica',
    color: silver,
    fontWeight: FontWeight.w500,
    fontSize: 20,
    letterSpacing: 1.2,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 4,
        offset: Offset(1, 1),
      ),
    ],
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Helvetica', // Clean premium font
    color: platinum,
    fontSize: 15,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  static final TextStyle dataValueStyle = TextStyle(
    fontFamily: 'Helvetica',
    color: silver,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 4,
        offset: Offset(1, 1),
      ),
    ],
  );
  
  static final TextStyle highlightValueStyle = TextStyle(
    fontFamily: 'Helvetica',
    color: platinum,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 4,
        offset: Offset(1, 1),
      ),
    ],
  );
  
  // Premium Y2K-inspired button styles with monochromatic approach
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: charcoal,
    foregroundColor: silver,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3), // Very squared corners - Y2K premium
    ),
    elevation: 1,
    shadowColor: Colors.black.withOpacity(0.4),
    textStyle: const TextStyle(
      fontFamily: 'Helvetica', // Clean premium font
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    ),
  );
  
  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: obsidian,
    foregroundColor: silver,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3), // Very squared corners - Y2K premium
      side: BorderSide(color: steelGray, width: 1),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
    textStyle: const TextStyle(
      fontFamily: 'Helvetica', // Clean premium font
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    ),
  );
  
  static final ButtonStyle goldButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: obsidian,
    foregroundColor: silver,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3), // Very squared corners - Y2K premium
      side: BorderSide(color: silver, width: 1),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
    textStyle: const TextStyle(
      fontFamily: 'Helvetica', // Clean premium font
      fontSize: 14,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    ),
  );
  
  // Y2K-inspired premium card styles
  static final BoxDecoration cardDecoration = BoxDecoration(
    gradient: y2kGradient,
    borderRadius: BorderRadius.circular(3), // Even more squared corners - classic Y2K
    border: Border.all(
      color: silver.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 5,
        spreadRadius: 0,
        offset: Offset(2, 2),
      ),
      BoxShadow(
        color: silver.withOpacity(0.1),
        blurRadius: 0,
        spreadRadius: 0,
        offset: Offset(1, 1),
      ),
    ],
  );
  
  static final BoxDecoration glassCardDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        silver.withOpacity(0.05),
        platinum.withOpacity(0.02),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(3), // Sharper corners for Y2K
    border: Border.all(
      color: silver.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 4,
        spreadRadius: 0,
        offset: Offset(2, 2),
      ),
    ],
  );
  
  static final BoxDecoration premiumCardDecoration = BoxDecoration(
    gradient: metallicGradient,
    borderRadius: BorderRadius.circular(3), // Very squared corners - essential Y2K detail
    border: Border.all(
      color: silver.withOpacity(0.5),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 4,
        spreadRadius: 0,
        offset: Offset(2, 2),
      ),
      // Slight inner highlight - very Y2K
      BoxShadow(
        color: silver.withOpacity(0.25),
        blurRadius: 0,
        spreadRadius: -1,
        offset: Offset(0, 0),
      ),
    ],
  );
  
  // Y2K-inspired inset panel (for status indicators)
  static final BoxDecoration insetPanelDecoration = BoxDecoration(
    color: jetBlack,
    borderRadius: BorderRadius.circular(3),
    border: Border.all(
      color: steelGray.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 2,
        spreadRadius: 0,
        offset: Offset(1, 1),
      ),
    ],
  );
  
  // Y2K-inspired premium slider design
  static final SliderThemeData sliderTheme = SliderThemeData(
    activeTrackColor: silver,
    inactiveTrackColor: steelGray.withOpacity(0.2),
    thumbColor: silver,
    overlayColor: silver.withOpacity(0.1),
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7), // Smaller sharp thumb
    trackHeight: 1.5, // Ultra thin track - Y2K precision aesthetic
    trackShape: RectangularSliderTrackShape(), // More squared - Y2K design essential
    overlayShape: RoundSliderOverlayShape(overlayRadius: 14), // Smaller overlay
    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
    valueIndicatorColor: jetBlack,
    valueIndicatorTextStyle: TextStyle(
      color: silver,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      fontFamily: 'Helvetica', // Clean premium font
      letterSpacing: 0.5, // Slight letter spacing for tech feel
    ),
  );
  
  // Y2K-inspired premium input decoration
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    fillColor: jetBlack,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(3)), // Very squared corners - Y2K premium
      borderSide: BorderSide(color: silver.withOpacity(0.5), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(3)), // Very squared corners - Y2K premium
      borderSide: BorderSide(color: silver.withOpacity(0.5), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(3)), // Very squared corners - Y2K premium
      borderSide: BorderSide(color: silver, width: 1.5),
    ),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    labelStyle: TextStyle(
      color: silver,
      fontFamily: 'Helvetica', // Clean premium font
      fontSize: 12,
      letterSpacing: 0.5,
    ),
    hintStyle: TextStyle(
      color: steelGray.withOpacity(0.7),
      fontFamily: 'Helvetica', // Clean premium font
      fontSize: 12,
      letterSpacing: 0.5,
    ),
  );

  // Y2K-inspired button styles
  static final ButtonStyle y2kButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: jetBlack,
    foregroundColor: silver,
    textStyle: TextStyle(
      fontFamily: 'Helvetica',
      fontSize: 13,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.8,
    ),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    minimumSize: Size(0, 32),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3),
      side: BorderSide(
        color: silver.withOpacity(0.5),
        width: 1,
      ),
    ),
    shadowColor: Colors.black.withOpacity(0.5),
    elevation: 2,
  );
}