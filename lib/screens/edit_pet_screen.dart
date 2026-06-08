import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class EditPetScreen extends StatefulWidget {
  final String petId;

  const EditPetScreen({super.key, required this.petId});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _ageController = TextEditingController();
  final _diseasesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  File? _imageFile;
  String? _photoUrl;
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

    if (response != null) {
      _nameController.text = response['name'] ?? '';
      _speciesController.text = response['species'] ?? '';
      _ageController.text = response['age']?.toString() ?? '';
      _diseasesController.text = response['diseases'] ?? '';
      _phoneController.text = response['ownerPhone'] ?? '';
      _addressController.text = response['address'] ?? '';
      _photoUrl = response['photoUrl'];
    }

    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _updatePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      String? uploadedUrl = _photoUrl;

      if (_imageFile != null) {
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
        final bytes = await _imageFile!.readAsBytes();

        await supabase.storage.from('pets').uploadBinary(fileName, bytes);
        uploadedUrl = supabase.storage.from('pets').getPublicUrl(fileName);
      }

      await supabase.from('pets').update({
        'name': _nameController.text,
        'species': _speciesController.text,
        'age': int.tryParse(_ageController.text),
        'diseases': _diseasesController.text,
        'ownerPhone': _phoneController.text,
        'address': _addressController.text,
        'photoUrl': uploadedUrl,
      }).eq('id', widget.petId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mascota actualizada")),
      );
      Navigator.pop(context, true); // 👈 devolvemos true para refrescar al volver
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
              : RefreshIndicator(
                  onRefresh: _loadPet,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                    key: ValueKey(_imageFile ?? _photoUrl),
                                    radius: 60,
                                    backgroundImage: _imageFile != null
                                        ? FileImage(_imageFile!)
                                        : _photoUrl != null
                                            ? NetworkImage(_photoUrl!)
                                            : const AssetImage(
                                                'assets/pet_placeholder.png')
                                                as ImageProvider,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _animatedField("Nombre", _nameController, Icons.pets,
                                  validator: (v) => v == null || v.isEmpty
                                      ? "Ingresa un nombre"
                                      : null),
                              _animatedField(
                                  "Especie", _speciesController, Icons.category),
                              _animatedField("Edad", _ageController, Icons.cake,
                                  keyboardType: TextInputType.number),
                              _animatedField("Enfermedades", _diseasesController,
                                  Icons.healing),
                              _animatedField("Teléfono", _phoneController,
                                  Icons.phone,
                                  keyboardType: TextInputType.phone),
                              _animatedField(
                                  "Dirección", _addressController, Icons.home),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _updatePet,
                                icon: const Icon(Icons.save),
                                label: const Text("Guardar cambios"),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                label: const Text("Cancelar"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _animatedField(String label, TextEditingController controller,
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
