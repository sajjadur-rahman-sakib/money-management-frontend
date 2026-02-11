import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:money/bloc/profile_bloc.dart';
import 'package:money/utils/app_snackbar.dart';
import 'package:money/utils/app_urls.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _image;
  bool _saving = false;
  late final String _initialName;

  @override
  void initState() {
    super.initState();
    _initialName = widget.profile['name']?.toString() ?? '';
    _nameController.text = _initialName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final nameChanged = name.isNotEmpty && name != _initialName;

    if (!nameChanged && _image == null) {
      AppSnackbar.showInfo(context, 'No changes to save.');
      return;
    }

    context.read<ProfileBloc>().add(
      UpdateProfileEvent(name: nameChanged ? name : null, picture: _image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pic = widget.profile['picture']?.toString();
    final normalizedPic = pic?.replaceAll('\\', '/');
    final imageUrl = (normalizedPic != null && normalizedPic.isNotEmpty)
        ? (normalizedPic.startsWith('http')
              ? normalizedPic
              : '${AppUrls.baseUrl}/$normalizedPic')
        : null;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdating) {
          setState(() => _saving = true);
        } else if (state is ProfileUpdated) {
          setState(() => _saving = false);
          AppSnackbar.showSuccess(
            context,
            'Your profile has been updated successfully.',
          );
          Navigator.pop(context, state.profile);
        } else if (state is ProfileUpdateError) {
          setState(() => _saving = false);
          AppSnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FC),
          elevation: 0,
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Color(0xFF1E2D4A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1E2D4A)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF9DB2CE),
                            width: 3,
                          ),
                          color: const Color(0xFFE8EDF5),
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!),
                                  fit: BoxFit.cover,
                                )
                              : (imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                        ),
                        child: _image == null && imageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF2D4379),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Color(0xFF2D4379),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D4379),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
