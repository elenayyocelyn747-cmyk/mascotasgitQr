import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  final _diseasesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  File? _selectedImage;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _savePet() async {
    setState(() => _loading = true);
    try {
      String? photoUrl;
      if (_selectedImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('pets').upload(fileName, _selectedImage!);
        photoUrl = supabase.storage.from('pets').getPublicUrl(fileName);
      }

      final userId = supabase.auth.currentUser!.id;
      await supabase.from('pets').insert({
        'user_id': userId,
        'name': _nameController.text.trim(),
        'species': _speciesController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'diseases': _diseasesController.text.trim(),
        'ownerPhone': _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'photoUrl': photoUrl,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mascota agregada correctamente")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Mascota")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : const AssetImage('assets/pet_placeholder.png')
                        as ImageProvider,
                child: _selectedImage == null
                    ? const Icon(Icons.camera_alt, size: 32, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre",
                prefixIcon: Icon(Icons.pets),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: "Especie",
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Edad",
                prefixIcon: Icon(Icons.cake),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _diseasesController,
              decoration: const InputDecoration(
                labelText: "Enfermedades",
                prefixIcon: Icon(Icons.medical_services),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Teléfono",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Dirección (opcional)",
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _savePet,
                    icon: const Icon(Icons.save),
                    label: const Text("Guardar"),
                  ),
          ],
        ),
      ),
    );
  }
}
