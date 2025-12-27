import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project1/core/theme/theme_provider.dart';
import 'package:project1/core/utils/app_responsives.dart';
import 'package:project1/core/utils/app_styles.dart';
import 'package:project1/features/auth/cubit/auth_cubit.dart';
import 'package:project1/features/auth/cubit/auth_state.dart';
import 'package:project1/features/auth/presentation/pages/profile_page.dart';
import 'package:project1/features/home/cubit/apartment_cubit.dart';
import 'package:project1/features/home/cubit/apartment_state.dart';
import 'package:project1/features/home/presentation/widgets/home_apartment_card.dart';
import 'package:project1/features/reservations/presentation/pages/owner_bookings_page.dart';
import 'package:provider/provider.dart';

class LandlordHomeScreen extends StatefulWidget {
  const LandlordHomeScreen({super.key});

  @override
  State<LandlordHomeScreen> createState() => _LandlordHomeScreenState();
}

class _LandlordHomeScreenState extends State<LandlordHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ApartmentCubit>().loadApartments();
    });
  }

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
    final themeProvider = context.watch<ThemeProvider>();

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Welcome, $userName',
          style: GoogleFonts.poppins(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeContent(userName, profileImage),
            OwnerBookingsPage(),
            const SizedBox(),
            _placeholderScreen(),
            const ProfilePage(),
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
                  child: Text(
                    'No apartments found',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onPrimary,
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppStyles.cardShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: cubit.search,
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: 'Search apartments...',
                hintStyle: GoogleFonts.poppins(
                  color: Theme.of(context).hintColor,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).iconTheme.color,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.tune, color: Theme.of(context).iconTheme.color),
            onPressed: () async {
              await Navigator.pushNamed(context, '/filtered_apartments');
              context.read<ApartmentCubit>().loadApartments();
            },
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
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _placeholderScreen() {
    return Center(
      child: ElevatedButton(
        onPressed: _notAvailable,
        child: Text(
          'Feature not available',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
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
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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
              _navItem(Icons.book, 'My Bookings', 1),
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
    final primary = Theme.of(context).colorScheme.primary;
    final unselected = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

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
              ? primary.withOpacity(0.1)
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
              color: isSelected ? primary : unselected,
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1.0,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isSelected ? primary : unselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
