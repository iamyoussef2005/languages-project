import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // الحصول على الثيم المناسب من الـ context
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 1,
          title: Text(
            "Edit Profile",
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: IconThemeData(color: colorScheme.onSurface),
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Personal Photo
                GestureDetector(
                  onTap: pickPersonalPhoto,
                  child: Column(
                    children: [
                      Text(
                        "Personal Photo",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: colorScheme.surfaceVariant,
                        backgroundImage: personalPhoto != null
                            ? FileImage(personalPhoto!)
                            : (widget.user.fullProfileImageUrl.isNotEmpty
                                ? NetworkImage(widget.user.fullProfileImageUrl)
                                : null),
                        child: personalPhoto == null &&
                                widget.user.fullProfileImageUrl.isEmpty
                            ? Icon(Icons.camera_alt,
                                size: 32, color: colorScheme.onSurface)
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ID Photo
                GestureDetector(
                  onTap: pickIdPhoto,
                  child: Column(
                    children: [
                      Text(
                        "ID Photo",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
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
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.onSurface.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: idPhoto == null &&
                                widget.user.fullIdImageUrl.isEmpty
                            ? Icon(Icons.credit_card,
                                size: 32, color: colorScheme.onSurface)
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // First name
                TextField(
                  controller: firstName,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    labelText: "First Name",
                    labelStyle: GoogleFonts.poppins(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Last name
                TextField(
                  controller: lastName,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    labelText: "Last Name",
                    labelStyle: GoogleFonts.poppins(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Birth date
                Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(12),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    tileColor: colorScheme.surface,
                    title: Text(
                      "Birth Date",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      birthDate != null
                          ? "${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}"
                          : "Select birth date",
                      style: GoogleFonts.poppins(),
                    ),
                    trailing: const Icon(Icons.calendar_today, size: 20),
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
                ),

                const SizedBox(height: 40),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
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
                    child: Text(
                      "Save",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
