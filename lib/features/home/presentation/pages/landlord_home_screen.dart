import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project1/core/utils/app_colors.dart';
import 'package:project1/core/utils/app_responsives.dart';
import 'package:project1/core/utils/app_styles.dart';
import 'package:project1/features/auth/cubit/auth_cubit.dart';
import 'package:project1/features/auth/cubit/auth_state.dart';
import 'package:project1/features/auth/presentation/pages/profile_page.dart';
import 'package:project1/features/home/cubit/apartment_cubit.dart';
import 'package:project1/features/home/cubit/apartment_state.dart';
import 'package:project1/features/home/presentation/widgets/home_apartment_card.dart';

class LandlordHomeScreen extends StatefulWidget {
  const LandlordHomeScreen({super.key});

  @override
  State<LandlordHomeScreen> createState() => _LandlordHomeScreenState();
}

class _LandlordHomeScreenState extends State<LandlordHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _notAvailable() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Feature not available',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This feature is not yet available.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, "/login");
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authState.user.isApproved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, "/pendingApproval");
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userName = authState.user.firstName;
    final profileImage = authState.user.profileImageUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(userName, profileImage), // 0 Home
            _placeholderScreen(),                      // 1 Favorites
            const SizedBox(),                          // 2 Add (push فقط)
            _placeholderScreen(),                      // 3 Messages
            const ProfilePage(),                       // 4 Profile
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent(String userName, String? profilePicture) {
    return BlocBuilder<ApartmentCubit, ApartmentState>(
      builder: (context, state) {
        final cubit = context.read<ApartmentCubit>();

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(userName)),
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveLayout.getPadding(context),
                child: _buildSearchBar(cubit),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: ResponsiveLayout.getPadding(context),
                child: _buildSectionTitle('Featured Apartments'),
              ),
            ),
            if (state is ApartmentLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (state is ApartmentEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text('No apartments found', style: GoogleFonts.poppins()),
                ),
              ),
            if (state is ApartmentLoaded)
              SliverPadding(
                padding: ResponsiveLayout.getPadding(context),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: HomeApartmentCard(
                        apartment: state.apartments[index],
                      ),
                    ),
                    childCount: state.apartments.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      padding: ResponsiveLayout.getPadding(context),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF6FA8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ApartmentCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppStyles.cardShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: cubit.search,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Search apartments...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () =>
                Navigator.pushNamed(context, '/filtered_apartments'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _placeholderScreen() {
    return Center(
      child: ElevatedButton(
        onPressed: _notAvailable,
        child: Text('Feature not available', style: GoogleFonts.poppins()),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [AppStyles.navShadow],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home, 'Home', 0),
              _navItem(Icons.favorite_border, 'Favorites', 1),
              _navItem(Icons.add, 'Add Apartment', 2),
              _navItem(Icons.message_outlined, 'Messages', 3),
              _navItem(Icons.person_outline, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 2) {
          Navigator.pushNamed(context, '/add_apartment');
          return;
        }
        setState(() => _selectedIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1.0,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
