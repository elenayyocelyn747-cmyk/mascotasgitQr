import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _petsFuture;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  void _loadPets() {
    final user = Supabase.instance.client.auth.currentUser;
    _petsFuture = Supabase.instance.client
        .from('pets')
        .select('*')
        .eq('user_id', user!.id);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Mascotas"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pets = snapshot.data!;
          if (pets.isEmpty) {
            return const Center(child: Text("No tienes mascotas registradas"));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final qrUrl =
                    "https://fxcjhomuwsdjhszarsjn.supabase.co/storage/v1/object/public/web/pet.html?petId=${pet["id"]}";

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: pet["photoUrl"] != null &&
                              pet["photoUrl"].toString().isNotEmpty
                          ? NetworkImage(pet["photoUrl"])
                          : const AssetImage("assets/default_pet.png")
                              as ImageProvider,
                      radius: 28,
                    ),
                    title: Text(
                      pet["name"] ?? "Sin nombre",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${pet["species"] ?? ""} • ${pet["age"] ?? ""} años",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (pet["diseases"] != null &&
                            pet["diseases"].toString().isNotEmpty)
                          Text("Enfermedades: ${pet["diseases"]}"),
                        if (pet["ownerPhone"] != null &&
                            pet["ownerPhone"].toString().isNotEmpty)
                          Text("Tel: ${pet["ownerPhone"]}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.qr_code, color: Colors.teal),
                      onPressed: () {
                        Navigator.pushNamed(context, '/qr', arguments: qrUrl);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/petDetail');
          if (result == true) {
            _refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Agregar mascota"),
      ),
    );
  }
}
