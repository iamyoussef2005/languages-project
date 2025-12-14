import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project1/features/auth/cubit/auth_state.dart';
import '../../cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF6557F5);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRejected) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pushReplacementNamed(context, "/login");
          }

          if (state is AuthPendingApproval) {
            Navigator.pushReplacementNamed(context, "/pendingApproval");
          }

          if (state is AuthLoggedIn) {
            if (state.user.isTenant) {
              Navigator.pushReplacementNamed(context, "/home");
            } else {
              Navigator.pushReplacementNamed(context, "/landlord_home");
            }
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // 🔵 Logo Circle
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: purple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    size: 55,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // 🏠 HomeStay Title
                Text(
                  "HomeStay",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Find your perfect home away from home",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                // 📱 Mobile Input
                _inputField(
                  controller: _phoneController,
                  icon: Icons.phone_rounded,
                  hint: "Mobile Number",
                  purple: purple,
                ),

                const SizedBox(height: 20),

                // 🔐 Password Input
                _inputField(
                  controller: _passwordController,
                  icon: Icons.lock_rounded,
                  hint: "Password",
                  purple: purple,
                  isPassword: true,
                  obscurePassword: _obscurePassword,
                  onTogglePassword: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                const SizedBox(height: 35),

                // 🔘 Login Button
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: state is AuthLoading
                          ? null
                          : () {
                              context.read<AuthCubit>().login(
                                phone: _phoneController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [purple, purple.withOpacity(0.85)],
                          ),
                        ),
                        child: Center(
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Login",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                // 📝 Register Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(color: Colors.grey.shade700),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/register"),
                      child: Text(
                        "Register",
                        style: GoogleFonts.poppins(
                          color: purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📦 Custom Input Field
  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required Color purple,
    bool isPassword = false,
    bool obscurePassword = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscurePassword,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),
          prefixIcon: Icon(icon, color: purple),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: purple,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
