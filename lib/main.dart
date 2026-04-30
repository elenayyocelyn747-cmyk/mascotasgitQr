import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Importa tus pantallas
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pet_detail_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/scan_qr_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fxcjhomuwsdjhszarsjn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4Y2pob211d3NkamhzemFyc2puIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NDczNTIsImV4cCI6MjA5MjAyMzM1Mn0.zKE_xtFY5gglCaitche817GVXIq7mX6uPOlqlzQbAr0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      initialRoute: Supabase.instance.client.auth.currentUser == null
          ? '/login'
          : '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/petDetail': (context) => const PetDetailScreen(),
        '/qr': (context) => const QrScreen(),
        '/scan': (context) => const ScanScreen(),
      },
    );
  }
}

//url: '  https://fxcjhomuwsdjhszarsjn.supabase.co   ',
//anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4Y2pob211d3NkamhzemFyc2puIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NDczNTIsImV4cCI6MjA5MjAyMzM1Mn0.zKE_xtFY5gglCaitche817GVXIq7mX6uPOlqlzQbAr0', // tu clave pública
//https://https://fxcjhomuwsdjhszarsjn.supabase.co/storage/v1/object/public/web/pet.html?petId=<id>
