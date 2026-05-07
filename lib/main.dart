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
      theme: ThemeData(
        primarySwatch: Colors.teal,
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
      initialRoute: session == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/addPet': (context) => const AddPetScreen(),
        '/editPet': (context) {
          final petId = ModalRoute.of(context)!.settings.arguments as String;
          return EditPetScreen(petId: petId);
        },
        '/petDetail': (context) {
          final petId = ModalRoute.of(context)!.settings.arguments as String;
          return PetDetailScreen(petId: petId);
        },
        '/qr': (context) => const QrScreen(),
      },
    );
  }
}


// url: 'https://fxcjhomuwsdjhszarsjn.supabase.co',
// anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4Y2pob211d3NkamhzemFyc2puIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NDczNTIsImV4cCI6MjA5MjAyMzM1Mn0.zKE_xtFY5gglCaitche817GVXIq7mX6uPOlqlzQbAr0',
// );



//url: '  https://fxcjhomuwsdjhszarsjn.supabase.co   ',
//anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4Y2pob211d3NkamhzemFyc2puIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NDczNTIsImV4cCI6MjA5MjAyMzM1Mn0.zKE_xtFY5gglCaitche817GVXIq7mX6uPOlqlzQbAr0', // tu clave pública
//https://https://fxcjhomuwsdjhszarsjn.supabase.co/storage/v1/object/public/web/pet.html?petId=<id>
