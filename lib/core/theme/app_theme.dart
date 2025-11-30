import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales - Orange et Blanc uniquement
  static const Color primaryOrange = Color(0xFFFF6B35); // Orange vif pro
  static const Color lightOrange = Color(0xFFFFA574);   // Orange clair
  static const Color darkOrange = Color(0xFFE85D2C);   // Orange foncé
  static const Color pureWhite = Color(0xFFFFFFFF);   // Blanc pur
  static const Color offWhite = Color(0xFFF8F9FA);    // Blanc cassé
  static const Color lightGray = Color(0xFFF5F5F5);   // Gris très clair

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF2C3E50);  // Texte foncé
  static const Color textSecondary = Color(0xFF7F8C8D); // Texte secondaire
  static const Color textLight = Color(0xFFBDC3C7);   // Texte très clair

  // Couleurs legacy pour compatibilité
  static const Color primaryGreen = primaryOrange; // Alias pour compatibilité
  static const Color lightGreen = lightOrange;     // Alias pour compatibilité  
  static const Color backgroundLight = pureWhite;  // Alias pour compatibilité
  static const Color errorRed = Color(0xFFE74C3C); // Rouge pour erreurs
  static const Color errorLight = Color(0xFFFDEDEC); // Rouge clair pour erreurs

  // Gradients subtils
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [primaryOrange, lightOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient legacy pour compatibilité
  static const LinearGradient greenGradient = orangeGradient; // Alias pour compatibilité

  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: primaryOrange,
    scaffoldBackgroundColor: pureWhite,
    colorScheme: const ColorScheme.light(
      primary: primaryOrange,
      secondary: lightOrange,
      surface: pureWhite,
      background: pureWhite,
      error: Color(0xFFE74C3C),
    ),
    
    // Typography minimaliste
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textLight,
      ),
    ),
    
    // AppBar minimaliste
    appBarTheme: const AppBarTheme(
      backgroundColor: pureWhite,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(
        color: primaryOrange,
        size: 24,
      ),
    ),
    
    // Bottom Navigation Bar minimaliste
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: pureWhite,
      selectedItemColor: primaryOrange,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // Cards minimalistes
    cardTheme: CardThemeData(
      color: pureWhite,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Elevated buttons minimalistes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: pureWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outline buttons minimalistes
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryOrange,
        side: const BorderSide(color: primaryOrange, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input fields minimalistes
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: offWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightGray, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(
        color: textLight,
        fontSize: 14,
      ),
    ),
    
    // Icons
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 24,
    ),
  );
}
