import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _nameFocus;

  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _nameFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  bool _isValidName(String name) {
    return name.trim().isNotEmpty && name.trim().length >= 2;
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
    });

    // Validate inputs
    if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    if (!_isValidPassword(_passwordController.text)) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    if (_isSignUp && !_isValidName(_nameController.text)) {
      setState(() {
        _errorMessage = 'Please enter your name (at least 2 characters)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);

      if (_isSignUp) {
        await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
      } else {
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      // Navigation is handled by the auth state watcher in main.dart
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 400 : double.infinity,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 0 : 24,
              vertical: 24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  _isSignUp ? 'Create Account' : 'Sign In',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isSignUp
                      ? 'Join Ankon-Chef to start organizing your recipes'
                      : 'Welcome back! Sign in to continue',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),

                // Name Field (Sign Up Only)
                if (_isSignUp) ...[
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      _emailFocus.requestFocus();
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Field
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    _passwordFocus.requestFocus();
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isLoading) {
                      _handleSubmit();
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isSignUp ? 'Create Account' : 'Sign In',
                          style: AppTextStyles.labelLarge,
                        ),
                ),
                const SizedBox(height: 20),

                // Toggle Mode Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp
                          ? 'Already have an account? '
                          : 'Don\'t have an account? ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleAuthMode,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _isSignUp ? 'Sign In' : 'Sign Up',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
