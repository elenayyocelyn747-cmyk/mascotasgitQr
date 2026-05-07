import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPetScreen extends StatefulWidget {
  final String petId;

  const EditPetScreen({super.key, required this.petId});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final supabase = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  final _diseasesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  File? _selectedImage;
  String? _photoUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    setState(() => _loading = true);
    final response =
        await supabase.from('pets').select().eq('id', widget.petId).single();

    if (!mounted) return;

    setState(() {
      if (response != null) {
        _nameController.text = response['name'] ?? '';
        _speciesController.text = response['species'] ?? '';
        _ageController.text = response['age']?.toString() ?? '';
        _diseasesController.text = response['diseases'] ?? '';
        _phoneController.text = response['ownerPhone'] ?? '';
        _addressController.text = response['address'] ?? '';
        _photoUrl = response['photoUrl'];
      }
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _updatePet() async {
    setState(() => _loading = true);
    try {
      String? photoUrl = _photoUrl;
      if (_selectedImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage.from('pets').upload(fileName, _selectedImage!);
        photoUrl = supabase.storage.from('pets').getPublicUrl(fileName);
      }

      await supabase.from('pets').update({
        'name': _nameController.text.trim(),
        'species': _speciesController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'diseases': _diseasesController.text.trim(),
        'ownerPhone': _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'photoUrl': photoUrl,
      }).eq('id', widget.petId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mascota actualizada correctamente")),
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
      appBar: AppBar(title: const Text("Editar Mascota")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_photoUrl != null
                              ? NetworkImage(_photoUrl!)
                              : const AssetImage('assets/pet_placeholder.png')
                                  as ImageProvider),
                      child: _selectedImage == null && _photoUrl == null
                          ? const Icon(Icons.camera_alt,
                              size: 32, color: Colors.white)
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
                      labelText: "Dirección",
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _updatePet,
                          icon: const Icon(Icons.save),
                          label: const Text("Actualizar"),
                        ),
                ],
              ),
            ),
    );
  }
}
