import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final authService = ref.read(authServiceProvider);

    return Drawer(
      child: Column(
        children: [
          userAsync.when(
            data: (user) => UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.surface,
                child: Text(
                  (user?.displayName ?? user?.email ?? 'U')[0].toUpperCase(),
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
              ),
              accountName: Text(
                user?.displayName ?? 'User',
                style: AppTextStyles.h4.copyWith(color: AppColors.textWhite),
              ),
              accountEmail: Text(
                user?.email ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
            ),
            loading: () => Container(
              height: 160,
              color: AppColors.primary,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            error: (err, stack) => Container(
              height: 160,
              color: AppColors.primary,
              child: const Center(
                child: Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  route: '/home',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.book,
                  title: 'My Recipes',
                  route: '/recipes',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.filter_list,
                  title: 'Filter Recipes',
                  route: '/filter-recipes',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.add_circle,
                  title: 'Add Recipe',
                  route: '/recipes/create',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_basket,
                  title: 'Ingredients',
                  route: '/ingredients',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.kitchen,
                  title: 'Pantry',
                  route: '/pantry',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Meal Planner',
                  route: '/meal-plan',
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    'Logout',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context); // Close drawer
                    await authService.signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final bool isSelected = GoRouterState.of(context).matchedLocation == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isSelected) {
          context.go(route);
        }
      },
    );
  }
}
