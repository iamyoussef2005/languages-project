import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project1/features/auth/cubit/auth_cubit.dart';
import 'package:project1/features/auth/cubit/auth_state.dart';
import 'package:project1/features/auth/presentation/pages/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeFont = GoogleFonts.poppins();

    // الحصول على ألوان الثيم باستخدام Theme.of(context)
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle textStylePrimary = Theme.of(context).textTheme.bodyLarge!;
    final TextStyle textStyleSecondary = Theme.of(context).textTheme.bodyMedium!;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushReplacementNamed(context, "/login");
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthLoggedIn) {
            return const Scaffold(body: Center(child: Text("Not logged in")));
          }

          final user = state.user;

          return Scaffold(
            backgroundColor: colorScheme.background,
            appBar: AppBar(
              title: Text(
                "Profile",
                style: themeFont.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: colorScheme.onBackground,
              centerTitle: true,
            ),

            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withOpacity(0.12),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: user.fullProfileImageUrl.isNotEmpty
                            ? NetworkImage(user.fullProfileImageUrl)
                            : null,
                        onBackgroundImageError: (_, __) {},
                        child: user.fullProfileImageUrl.isEmpty
                            ? const Icon(Icons.person, size: 45)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${user.firstName} ${user.lastName}",
                        style: themeFont.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: user.isApproved
                              ? colorScheme.primary
                              : colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.isApproved ? "APPROVED" : "PENDING",
                          style: themeFont.copyWith(
                            color: colorScheme.onSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withOpacity(0.12),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personal Information",
                        style: themeFont.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _infoTile(
                        context, // تمرير context هنا
                        icon: Icons.person,
                        label: "Name",
                        value: "${user.firstName} ${user.lastName}",
                        font: themeFont,
                      ),

                      _infoTile(
                        context, // تمرير context هنا
                        icon: Icons.phone,
                        label: "Mobile",
                        value: user.phone,
                        font: themeFont,
                      ),

                      _infoTile(
                        context, // تمرير context هنا
                        icon: Icons.calendar_today,
                        label: "Date of Birth",
                        value: user.birthDate.toString().split(' ')[0],
                        font: themeFont,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ===== Settings =====
                _settingsTile(
                  context,
                  icon: Icons.edit,
                  title: "Edit Profile",
                  subtitle: "Modify your personal information",
                  font: themeFont,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditProfilePage(user)),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _settingsTile(
                  context,
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  subtitle: "Get assistance",
                  font: themeFont,
                  onTap: () {},
                ),

                const SizedBox(height: 12),

                // ===== Logout =====
                _settingsTile(
                  context,
                  icon: Icons.logout,
                  title: "Logout",
                  subtitle: "Sign out of your account",
                  font: themeFont,
                  iconColor: colorScheme.error,
                  textColor: colorScheme.error,
                  onTap: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // تعديل الأسلوب لتمرير context
  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required TextStyle font,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: font.copyWith(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: font.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // تعديل الأسلوب لتمرير context
  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required TextStyle font,
    required VoidCallback onTap,
    Color iconColor = const Color.fromARGB(221, 44, 151, 17),
    Color textColor = const Color.fromARGB(221, 66, 189, 8),
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.12),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: font.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: font.copyWith(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color.fromARGB(115, 29, 70, 184),
            ),
          ],
        ),
      ),
    );
  }
}
