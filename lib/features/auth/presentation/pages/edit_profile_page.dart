import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/features/auth/cubit/profile_cubit.dart';

import 'package:project1/features/auth/cubit/auth_cubit.dart';
import 'package:project1/data/models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage(this.user, {super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController firstName;
  late TextEditingController lastName;
  DateTime? birthDate;
  File? personalPhoto;
  File? idPhoto;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    firstName = TextEditingController(text: widget.user.firstName);
    lastName = TextEditingController(text: widget.user.lastName);
    birthDate = widget.user.birthDate;
  }

  Future<void> pickPersonalPhoto() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => personalPhoto = File(picked.path));
    }
  }

  Future<void> pickIdPhoto() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      setState(() => idPhoto = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          context.read<AuthCubit>().updateUser(state.user);
          Navigator.pop(context);
        }

        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Edit Profile")),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Personal Photo
                GestureDetector(
                  onTap: pickPersonalPhoto,
                  child: Column(
                    children: [
                      const Text(
                        "Personal Photo",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: personalPhoto != null
                            ? FileImage(personalPhoto!)
                            : (widget.user.fullProfileImageUrl.isNotEmpty
                                ? NetworkImage(
                                    widget.user.fullProfileImageUrl)
                                : null),
                        child: personalPhoto == null &&
                                widget.user.fullProfileImageUrl.isEmpty
                            ? const Icon(Icons.camera_alt, size: 32)
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ID Photo
                GestureDetector(
                  onTap: pickIdPhoto,
                  child: Column(
                    children: [
                      const Text(
                        "ID Photo",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          image: idPhoto != null
                              ? DecorationImage(
                                  image: FileImage(idPhoto!),
                                  fit: BoxFit.cover,
                                )
                              : (widget.user.fullIdImageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          widget.user.fullIdImageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: idPhoto == null &&
                                widget.user.fullIdImageUrl.isEmpty
                            ? const Icon(Icons.credit_card, size: 32)
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: firstName,
                  decoration:
                      const InputDecoration(labelText: "First Name"),
                ),
                TextField(
                  controller: lastName,
                  decoration: const InputDecoration(labelText: "Last Name"),
                ),

                const SizedBox(height: 20),

                ListTile(
                  title: const Text("Birth Date"),
                  subtitle: Text(
                    birthDate != null
                        ? "${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}"
                        : "Select birth date",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: birthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => birthDate = picked);
                    }
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (birthDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please select a birth date")),
                      );
                      return;
                    }

                    context.read<ProfileCubit>().updateProfile(
                          firstName: firstName.text,
                          lastName: lastName.text,
                          birthDate: birthDate!,
                          personalPhoto: personalPhoto,
                          idPhoto: idPhoto,
                        );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
