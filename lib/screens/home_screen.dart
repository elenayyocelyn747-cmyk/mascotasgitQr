import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> pets = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() => _loading = true);
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('pets')
        .select()
        .eq('user_id', userId);

    if (!mounted) return;
    setState(() {
      pets = response ?? [];
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Mascotas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : pets.isEmpty
              ? const Center(child: Text("No tienes mascotas registradas"))
              : ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: pet['photoUrl'] != null
                              ? NetworkImage(pet['photoUrl'])
                              : const AssetImage('assets/pet_placeholder.png')
                                  as ImageProvider,
                        ),
                        title: Text(pet['name'] ?? 'Sin nombre'),
                        subtitle: Text(pet['species'] ?? 'Especie desconocida'),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/petDetail',
                            arguments: pet['id'],
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/addPet');
          _loadPets();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

