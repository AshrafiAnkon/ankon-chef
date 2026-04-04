import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      body: Stack(
        children: [
          // Background Decorative elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withAlpha(25),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withAlpha(25),
              ),
            ),
          ),

          // Main layout
          if (isDesktop)
            Row(
              children: [
                Expanded(flex: 7, child: _buildHeroSection(context, isDesktop)),
                Expanded(
                  flex: 5,
                  child: _buildContentSection(context, authService, isDesktop),
                ),
              ],
            )
          else
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(context, isDesktop),
                  _buildContentSection(context, authService, isDesktop),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return SizedBox(
      height: isDesktop ? double.infinity : 400,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBo1dCAdSUWaflPTMswbFNO-6ytxpdH0XvW1rQ0QmuqDmQhqYqMgYCnbjnd1F2sy5qw-Pe2tQ5l7fffiGq5HDvD-FNIsnFIjx_99c-SfphGY8svCjJUSB1r13YisihvPO5025yzAmJ7sWB9PPHEIOpcntURSWVEMokP-vTdfYgaJL_F07Q88O_rUalyyLa5e_Zzkt8uGvRghJywC5KirdBJEyD-eKmvvnIHWTQxmJytj0PvTkiTPDY4q3N0txhILVZHk-f8OuwbSR8',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.background.withAlpha(100),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          if (isDesktop)
            Positioned(
              top: 48,
              left: 48,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ankon-Chef',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    dynamic authService,
    bool isDesktop,
  ) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 48,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ankon-Chef',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

          if (!isDesktop) const SizedBox(height: 32),

          RichText(
            text: TextSpan(
              style: AppTextStyles.display2.copyWith(
                color: AppColors.onBackground,
                height: 1.1,
              ),
              children: const [
                TextSpan(text: 'Cook '),
                TextSpan(
                  text: 'Smarter,\n',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(text: 'Every Day'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The modern recipe vault that organizes your culinary life—from pantry to plate.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: () async {
              try {
                await authService.signInWithGoogle();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to sign in: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLowest,
              foregroundColor: AppColors.onSurface,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.black12),
              ),
              minimumSize: const Size(double.infinity, 60),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.g_mobiledata,
                  size: 32,
                  color: Colors.blue,
                ), // Placeholder for google icon
                const SizedBox(width: 12),
                Text('Sign in with Google', style: AppTextStyles.labelLarge),
              ],
            ),
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: () {
              context.push('/email-login');
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryContainer.withAlpha(25),
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Continue with Email', style: AppTextStyles.labelLarge),
          ),

          const SizedBox(height: 48),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.inventory_2, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text('Pantry Sync', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 4),
                      Text(
                        'We find recipes based on what you already have.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: 8),
                      Text('Smart Planner', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Auto-generate weekly menus that save time.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 64),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Learn more',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    'Privacy Policy',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (isDesktop)
                Text(
                  '© 2024 Ankon-Chef Inc.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.outline,
                  ),
                ),
            ],
          ),
          if (!isDesktop) ...[
            const SizedBox(height: 16),
            Text(
              '© 2024 Ankon-Chef Inc.',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
