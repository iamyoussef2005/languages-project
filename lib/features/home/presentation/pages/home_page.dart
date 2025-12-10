import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project1/core/utils/app_colors.dart';
import 'package:project1/core/utils/app_responsives.dart';
import 'package:project1/core/utils/app_styles.dart';
import 'package:project1/features/auth/cubit/auth_cubit.dart';
import 'package:project1/features/auth/cubit/auth_state.dart';
import 'package:project1/features/auth/presentation/pages/profile_page.dart';
import 'package:project1/features/home/cubit/apartment_cubit.dart';
import 'package:project1/features/home/cubit/apartment_state.dart';
import 'package:project1/features/home/presentation/widgets/home_apartment_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        title: const Text('Feature not available', style: TextStyle(fontFamily: "Poppins")),
        content: const Text('This feature is not yet available.', style: TextStyle(fontFamily: "Poppins")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(fontFamily: "Poppins")),
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

    String userName = authState.user.firstName;
    String? profileImage = authState.user.profileImageUrl;

    return Scaffold(
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildHomeContent(userName, profileImage)
            : _placeholderScreen(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent(String userName, String? profilePicture) {
    return BlocBuilder<ApartmentCubit, ApartmentState>(
      builder: (context, state) {
        final cubit = context.read<ApartmentCubit>();

        return RefreshIndicator(
          onRefresh: () async {
            await cubit.loadApartments();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(userName, profilePicture)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveLayout.getPadding(context),
                  child: _buildSearchBar(cubit),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveLayout.getPadding(context),
                  child: _buildSectionTitle("Featured Apartments"),
                ),
              ),
              if (state is ApartmentLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (state is ApartmentEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "No apartments found",
                      style: TextStyle(fontFamily: "Poppins"),
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
          ),
        );
      },
    );
  }

  Widget _buildAppBar(String name, String? photo) {
    return Padding(
      padding: ResponsiveLayout.getPadding(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: ResponsiveLayout.getFontSize(context, base: 14),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: ResponsiveLayout.getFontSize(context, base: 22),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _notAvailable,
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey[300],
              backgroundImage: photo != null ? NetworkImage(photo) : null,
              child: photo == null
                  ? const Icon(Icons.person)
                  : null,
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppStyles.cardShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: cubit.search,
              style: const TextStyle(fontFamily: "Poppins"),
              decoration: const InputDecoration(
                hintText: "Search apartments...",
                hintStyle: TextStyle(fontFamily: "Poppins"),
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              await Navigator.pushNamed(context, "/filtered_apartments");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: "Poppins",
        fontSize: ResponsiveLayout.getFontSize(context, base: 20),
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _placeholderScreen() {
    return Center(
      child: ElevatedButton(
        onPressed: _notAvailable,
        child: const Text(
          "Feature not available",
          style: TextStyle(fontFamily: "Poppins"),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [AppStyles.navShadow],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home, "Home", 0),
              _navItem(Icons.favorite_border, "Favorites", 1),
              _navItem(Icons.calendar_today, "Bookings", 2),
              _navItem(Icons.message_outlined, "Messages", 3),
              _navItem(Icons.person_outline, "Profile", 4),
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
        setState(() => _selectedIndex = index);

        if (index == 2) {
          Navigator.pushNamed(context, "/bookings");
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          );
        } else if (index != 0) {
          _notAvailable();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: "Poppins",
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
