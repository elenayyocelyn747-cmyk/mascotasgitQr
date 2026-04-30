import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({super.key});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final nameController = TextEditingController();
  final speciesController = TextEditingController();
  final ageController = TextEditingController();
  final diseasesController = TextEditingController();
  final ownerPhoneController = TextEditingController();
  final addressController = TextEditingController();

  Uint8List? _imageBytes;
  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> savePet() async {
    if (_imageBytes == null) return;

    setState(() => isLoading = true);

    final user = Supabase.instance.client.auth.currentUser;

    // Subir imagen a Supabase Storage
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    await Supabase.instance.client.storage
        .from('pets')
        .uploadBinary(fileName, _imageBytes!);

    final publicUrl = Supabase.instance.client.storage
        .from('pets')
        .getPublicUrl(fileName);

    // Insertar mascota en la tabla con campos extra
    await Supabase.instance.client.from('pets').insert({
      'name': nameController.text,
      'species': speciesController.text,
      'age': int.tryParse(ageController.text) ?? 0,
      'photoUrl': publicUrl,
      'diseases': diseasesController.text,
      'ownerPhone': ownerPhoneController.text,
      'address': addressController.text.isEmpty ? null : addressController.text,
      'user_id': user!.id,
    });

    setState(() => isLoading = false);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Mascota")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nombre",
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: speciesController,
              decoration: const InputDecoration(
                labelText: "Especie",
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Edad",
                prefixIcon: Icon(Icons.cake),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: diseasesController,
              decoration: const InputDecoration(
                labelText: "Enfermedades",
                prefixIcon: Icon(Icons.healing),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ownerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Número del dueño",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Dirección (opcional)",
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _imageBytes != null
                ? Image.memory(_imageBytes!, height: 150)
                : const Text("No hay imagen seleccionada"),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Seleccionar foto"),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isLoading ? null : savePet,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(isLoading ? "Guardando..." : "Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
