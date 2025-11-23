import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/contact_list_screen.dart';
import 'services/contact_service.dart';
import 'utils/constants.dart';

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
      title: AppConstants.appName,
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
      primaryColor: Color(AppConstants.primaryColor),
      colorScheme: ColorScheme.light(
        primary: Color(AppConstants.primaryColor),
        secondary: Color(AppConstants.secondaryColor),
        surface: Colors.white,
        background: Color(AppConstants.backgroundColor),
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: Color(AppConstants.backgroundColor),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(AppConstants.textColor),
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(AppConstants.textColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppConstants.primaryColor),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Scaffold _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(AppConstants.primaryColor))),
            SizedBox(height: 20),
            Text('Chargement...', style: TextStyle(color: Color(AppConstants.primaryColor))),
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
      return false;
    }
  }
}