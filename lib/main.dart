import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'screens/booking_history_screen.dart';
import 'models/movie.dart';
import 'firebase_options.dart'; // Make sure you have this file from 'flutterfire configure'
import 'package:firebase_app_check/firebase_app_check.dart';  // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Sign out any existing user when app starts
  await FirebaseAuth.instance.signOut();

  // Initialize Firebase App Check with reCAPTCHA v3
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
    webProvider: ReCaptchaV3Provider('6Ldu_P4rAAAAALLJJMnQDxNGkSi-zGTGIshe_F2s'),
  );


  runApp(const CinecMovieApp());
}

class CinecMovieApp extends StatelessWidget {
  const CinecMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinec Movie Booking',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF13151A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E2749),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Always start with login screen
      // Your routes are used for navigation after login
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/booking-history': (context) => const BookingHistoryScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/movie-detail') {
          final movie = settings.arguments as Movie;
          return MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          );
        }
        return null;
      },
    );
  }
}