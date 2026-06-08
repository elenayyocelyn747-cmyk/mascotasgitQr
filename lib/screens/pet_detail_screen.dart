import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalle de mascota",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
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
        child: SafeArea(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('pets').stream(primaryKey: ['id']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final pets = snapshot.data!;
              final pet = pets.firstWhere(
                (p) =>
                    p['id'] == widget.petId &&
                    p['user_id'] == supabase.auth.currentUser!.id,
                orElse: () => {},
              );

              if (pet.isEmpty) {
                return Center(
                  child: Text(
                    "Mascota no encontrada",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Hero(
                            tag: pet['id'],
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: pet['photoUrl'] != null
                                  ? NetworkImage(pet['photoUrl'])
                                  : const AssetImage(
                                      'assets/pet_placeholder.png')
                                      as ImageProvider,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            pet['name'] ?? 'Sin nombre',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _infoRow(Icons.pets, "Especie", pet['species']),
                        _infoRow(Icons.cake, "Edad", pet['age']),
                        _infoRow(Icons.healing, "Enfermedades", pet['diseases']),
                        _infoRow(Icons.phone, "Teléfono", pet['ownerPhone']),
                        _infoRow(Icons.home, "Dirección", pet['address']),
                        const SizedBox(height: 24),

                        Column(
                          children: [
                            _actionButton(
                              color: Colors.teal,
                              icon: Icons.qr_code,
                              label: "Ver QR",
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/qrScreen',
                                  arguments: pet['id'],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _actionButton(
                              color: Colors.orange,
                              icon: Icons.edit,
                              label: "Editar",
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/editPet',
                                  arguments: pet['id'],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _actionButton(
                              color: Colors.redAccent,
                              icon: Icons.delete,
                              label: "Eliminar",
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(
                                      "Confirmar eliminación",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      "¿Seguro que quieres eliminar esta mascota?",
                                      style: GoogleFonts.roboto(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("Cancelar"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text("Eliminar"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await supabase
                                      .from('pets')
                                      .delete()
                                      .eq('id', pet['id']);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Mascota eliminada")),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: GoogleFonts.roboto(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
