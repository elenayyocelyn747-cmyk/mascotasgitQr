import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pets = [];
  String _searchQuery = "";
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

    setState(() {
      pets = List<Map<String, dynamic>>.from(response);
      _loading = false;
    });
  }

  void _filterPets(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<void> _toggleFavorite(Map<String, dynamic> pet) async {
    final newValue = !(pet['isFavorite'] ?? false);

    await supabase
        .from('pets')
        .update({'isFavorite': newValue})
        .eq('id', pet['id']);

    await _loadPets(); // refrescamos manualmente

    // feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newValue ? "⭐ Se agregó a favoritos" : "❌ Se quitó de favoritos",
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filtrar por búsqueda
    final filteredPets = pets.where((pet) {
      final name = (pet['name'] ?? '').toString().toLowerCase();
      final species = (pet['species'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) || species.contains(_searchQuery);
    }).toList();

    // Ordenar favoritos primero
    final sortedPets = [...filteredPets]
      ..sort((a, b) {
        final favA = a['isFavorite'] ?? false;
        final favB = b['isFavorite'] ?? false;
        return favB.toString().compareTo(favA.toString());
      });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.teal, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                "Mis Mascotas",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.teal,
              elevation: 6,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
            ),

            // 👇 Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: _filterPets,
                style: GoogleFonts.roboto(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Buscar por nombre o especie...",
                  hintStyle: GoogleFonts.roboto(),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // 👇 Lista con pull-to-refresh
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadPets,
                      child: sortedPets.isEmpty
                          ? ListView(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      "No se encontraron mascotas",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: sortedPets.length,
                              itemBuilder: (context, index) {
                                final pet = sortedPets[index];
                                return Card(
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: Hero(
                                      tag: "pet_${pet['id']}",
                                      child: pet['photoUrl'] != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              child: Image.network(
                                                pet['photoUrl'],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const CircleAvatar(
                                              child: Icon(Icons.pets),
                                            ),
                                    ),
                                    title: Text(
                                      pet['name'] ?? 'Sin nombre',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      pet['species'] ?? 'Sin especie',
                                      style: GoogleFonts.roboto(),
                                    ),
                                    trailing: IconButton(
                                      icon: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        transitionBuilder: (child, anim) =>
                                            ScaleTransition(scale: anim, child: child),
                                        child: Icon(
                                          (pet['isFavorite'] ?? false)
                                              ? Icons.star
                                              : Icons.star_border,
                                          key: ValueKey(pet['isFavorite']),
                                          color: Colors.orange,
                                        ),
                                      ),
                                      onPressed: () => _toggleFavorite(pet),
                                    ),
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
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.pushNamed(context, '/addPet').then((_) => _loadPets());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
