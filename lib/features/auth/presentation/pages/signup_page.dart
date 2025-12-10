import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/features/auth/cubit/auth_cubit.dart';
import 'package:project1/features/auth/cubit/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  DateTime? birthDate;
  File? profileImage;
  File? idImage;

  Future pickImage(bool isProfile) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        if (isProfile) {
          profileImage = File(picked.path);
        } else {
          idImage = File(picked.path);
        }
      });
    }
  }

  bool _isTenant = true;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6C3FFA);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            ),
          );
        }

        if (state is AuthPendingApproval) {
          Navigator.of(context, rootNavigator: true).maybePop();
          Navigator.pushReplacementNamed(context, "/pendingApproval");
        }

        if (state is AuthError) {
          Navigator.of(context, rootNavigator: true).maybePop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7FF),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Create Account",
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 22,
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Profile Image
              GestureDetector(
                onTap: () => pickImage(true),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7D5DF6), Color(0xFF6C3FFA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.25),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null,
                    child: profileImage == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 38,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              _styledInput(
                "First Name",
                firstNameController,
                icon: Icons.person,
              ),
              const SizedBox(height: 20),

              _styledInput("Last Name", lastNameController, icon: Icons.person),
              const SizedBox(height: 20),

              _styledInput(
                "Phone Number",
                phoneController,
                icon: Icons.phone,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              _styledInput(
                "Password",
                passwordController,
                icon: Icons.lock,
                keyboard: TextInputType.visiblePassword,
                isPassword: true,
              ),
              const SizedBox(height: 20),

              _styledInput(
                "Confirm Password",
                confirmPasswordController,
                icon: Icons.lock,
                keyboard: TextInputType.visiblePassword,
                isPassword: true,
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _isTenant ? "Tenant" : "Owner",
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6C3FFA),
                    ),
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Tenant",
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: Color(0xFF6C3FFA),
                            ),
                            SizedBox(width: 10),
                            Text("Tenant"),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Owner",
                        child: Row(
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              color: Color(0xFF6C3FFA),
                            ),
                            SizedBox(width: 10),
                            Text("Owner"),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _isTenant =
                            value == "Tenant"; // نفس اللوجيك القديم تماماً
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Date of Birth
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime(2025),
                  );
                  if (date != null) {
                    setState(() => birthDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, color: purple),
                      const SizedBox(width: 12),
                      Text(
                        birthDate == null
                            ? "Date of Birth"
                            : birthDate!.toString().split(" ").first,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins",
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ID Upload
              GestureDetector(
                onTap: () => pickImage(false),
                child: Container(
                  height: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: idImage != null ? purple : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: idImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.credit_card, color: purple, size: 34),
                            SizedBox(height: 10),
                            Text(
                              "Tap to upload ID image",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(idImage!, fit: BoxFit.cover),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // SIGN UP BUTTON
              Container(
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7D5DF6), Color(0xFF6C3FFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withOpacity(0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // VALIDATION LOGIC — untouched
                    if (firstNameController.text.trim().isEmpty ||
                        lastNameController.text.trim().isEmpty ||
                        phoneController.text.trim().isEmpty ||
                        profileImage == null ||
                        idImage == null ||
                        birthDate == null ||
                        passwordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all required fields"),
                        ),
                      );
                      return;
                    }
                    if (passwordController.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Password must be at least 8 characters",
                          ),
                        ),
                      );
                      return;
                    }
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Passwords do not match")),
                      );
                      return;
                    }

                    context.read<AuthCubit>().register(
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      phone: phoneController.text.trim(),
                      birthDate: birthDate!,
                      profileImage: profileImage!,
                      idImage: idImage!,
                      password: passwordController.text,
                      isTenant: _isTenant,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styledInput(
    String hint,
    TextEditingController controller, {
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool isPassword = false,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscure = isPassword;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboard,
            style: const TextStyle(fontFamily: "Poppins", fontSize: 16),
            decoration: InputDecoration(
              labelText: hint,
              labelStyle: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 15,
                color: Colors.grey,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF6C3FFA)),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF6C3FFA),
                      ),
                      onPressed: () => setState(() => obscure = !obscure),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        );
      },
    );
  }
}
