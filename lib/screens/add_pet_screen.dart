import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  final _diseasesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  File? _imageFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _addPet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      String? uploadedUrl;

      if (_imageFile != null) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
        final bytes = await _imageFile!.readAsBytes();

        await supabase.storage.from('pets').uploadBinary(fileName, bytes);
        uploadedUrl = supabase.storage.from('pets').getPublicUrl(fileName);
      }

      final userId = supabase.auth.currentUser!.id;

      await supabase.from('pets').insert({
        'name': _nameController.text,
        'species': _speciesController.text,
        'age': int.tryParse(_ageController.text),
        'diseases': _diseasesController.text,
        'ownerPhone': _phoneController.text,
        'address': _addressController.text,
        'photoUrl': uploadedUrl,
        'user_id': userId,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mascota registrada")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        // 👇 Fondo con gradiente adaptado
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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: CircleAvatar(
                                  key: ValueKey(_imageFile),
                                  radius: 60,
                                  backgroundImage: _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : const AssetImage(
                                          'assets/pet_placeholder.png')
                                          as ImageProvider,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _animatedField(_nameController, "Nombre", Icons.pets,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Ingresa un nombre"
                                    : null),
                            _animatedField(
                                _speciesController, "Especie", Icons.category),
                            _animatedField(_ageController, "Edad", Icons.cake,
                                keyboardType: TextInputType.number),
                            _animatedField(_diseasesController, "Enfermedades",
                                Icons.healing),
                            _animatedField(_phoneController, "Teléfono",
                                Icons.phone,
                                keyboardType: TextInputType.phone),
                            _animatedField(
                                _addressController, "Dirección", Icons.home),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _addPet,
                              icon: const Icon(Icons.save),
                              label: const Text("Guardar"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _animatedField(TextEditingController controller, String label,
      IconData icon,
      {String? Function(String?)? validator,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          );
        },
        child: TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ),
    );
  }
}
