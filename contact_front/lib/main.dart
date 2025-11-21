import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/contact_list_screen.dart';
import 'services/contact_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(ContactApp());
}

class ContactApp extends StatelessWidget {
  final ContactService _contactService = ContactService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Pro',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: FutureBuilder<bool>(
        future: _isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }

          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? ContactListScreen() : LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/contacts': (context) => ContactListScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primaryColor: Color(0xFF0066CC),
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF0066CC),
        secondary: Color(0xFF00A8FF),
        surface: Colors.white,
        background: Color(0xFFF0F8FF),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: Color(0xFFF0F8FF),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF003366),
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF003366),
        ),
        iconTheme: IconThemeData(color: Color(0xFF0066CC)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE0F0FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE0F0FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF0066CC), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: Color(0xFF6699CC)),
        hintStyle: TextStyle(color: Color(0xFF99C2FF)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0066CC),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Scaffold _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF0066CC)),
            ),
            SizedBox(height: 20),
            Text(
              'Chargement...',
              style: TextStyle(
                color: Color(0xFF0066CC),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _isUserLoggedIn() async {
    try {
      final userId = await _contactService.getCurrentUserId();
      return userId != null;
    } catch (e) {
      print('Erreur vérification connexion: $e');
      return false;
    }
  }
}