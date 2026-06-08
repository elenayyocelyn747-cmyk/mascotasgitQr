import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/add_pet_screen.dart';
import 'screens/edit_pet_screen.dart';
import 'screens/pet_detail_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
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
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Manager',

      // 👇 Tema claro
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],

        // ⚠️ Opción 2 (solo si tu analyzer insiste en CardThemeData)
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),

      // 👇 Tema oscuro
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
        ),
      ),

      // 👇 Usa el modo del sistema
      themeMode: ThemeMode.system,

      initialRoute: session == null ? '/login' : '/home',
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/login':
            builder = (context) => const LoginScreen();
            break;
          case '/register':
            builder = (context) => const RegisterScreen();
            break;
          case '/home':
            builder = (context) => const HomeScreen();
            break;
          case '/profile':
            builder = (context) => const ProfileScreen();
            break;
          case '/addPet':
            builder = (context) => const AddPetScreen();
            break;
          case '/editPet':
            final petId = settings.arguments as String;
            builder = (context) => EditPetScreen(petId: petId);
            break;
          case '/petDetail':
            final petId = settings.arguments as String;
            builder = (context) => PetDetailScreen(petId: petId);
            break;
          case '/qrScreen':
            final petId = settings.arguments as String;
            builder = (context) => QrScreen(petId: petId);
            break;
          case '/scanQr':
            builder = (context) => const ScanQrScreen();
            break;
          default:
            builder = (context) => const HomeScreen();
        }

        return PageRouteBuilder(
          pageBuilder: (context, __, ___) => builder(context),
          transitionsBuilder: (context, animation, __, child) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.2, 0.0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    );
  }
}
