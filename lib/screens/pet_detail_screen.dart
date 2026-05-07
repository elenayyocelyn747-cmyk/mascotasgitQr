import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? pet;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    setState(() => _loading = true);
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('pets')
        .select()
        .eq('id', widget.petId)
        .eq('user_id', userId)
        .maybeSingle();

    if (!mounted) return;

    setState(() {
      pet = response;
      _loading = false;
    });
  }

  Future<void> _deletePet() async {
    final userId = supabase.auth.currentUser!.id;
    await supabase
        .from('pets')
        .delete()
        .eq('id', widget.petId)
        .eq('user_id', userId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mascota eliminada")),
    );
    Navigator.pop(context);
  }

void _showQrCode() {
  final qrUrl = 
      "https://lenas-projects-db973962.vercel.app/pet.html?id=${widget.petId}";

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Código QR"),
      content: SizedBox(
        height: 220,
        width: 220,
        child: Center(
          child: QrImageView(
            data: qrUrl,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Mascota")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : pet == null
              ? const Center(child: Text("Mascota no encontrada"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: pet!['photoUrl'] != null
                                  ? NetworkImage(pet!['photoUrl'])
                                  : const AssetImage('assets/pet_placeholder.png')
                                      as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pet!['name'] ?? 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Especie: ${pet!['species'] ?? 'N/A'}"),
                          Text("Edad: ${pet!['age'] ?? 'N/A'}"),
                          Text("Enfermedades: ${pet!['diseases'] ?? 'N/A'}"),
                          Text("Teléfono: ${pet!['ownerPhone'] ?? 'N/A'}"),
                          Text("Dirección: ${pet!['address'] ?? 'N/A'}"),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/editPet',
                                    arguments: widget.petId,
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Editar"),
                              ),
                              ElevatedButton.icon(
                                onPressed: _deletePet,
                                icon: const Icon(Icons.delete),
                                label: const Text("Eliminar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _showQrCode,
                                icon: const Icon(Icons.qr_code),
                                label: const Text("QR"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
