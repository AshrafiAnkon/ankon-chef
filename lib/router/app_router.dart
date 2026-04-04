import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/auth_provider.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/email_login_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/recipes_screen.dart';
import '../ui/screens/create_recipe_screen.dart';
import '../ui/screens/recipe_detail_screen.dart';
import '../ui/screens/ingredients_screen.dart';
import '../ui/screens/pantry_screen.dart';
import '../ui/screens/meal_plan_screen.dart';
import '../ui/screens/filter_recipes_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/email-login';

      // Redirect to home if logged in and trying to access login
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      // Redirect to login if not logged in and trying to access protected routes
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/email-login',
        name: 'email-login',
        builder: (context, state) => const EmailLoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/recipes',
        name: 'recipes',
        builder: (context, state) => const RecipesScreen(),
      ),
      GoRoute(
        path: '/recipes/create',
        name: 'create-recipe',
        builder: (context, state) => const CreateRecipeScreen(),
      ),
      GoRoute(
        path: '/recipes/edit/:id',
        name: 'edit-recipe',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CreateRecipeScreen(editRecipeId: id);
        },
      ),
      GoRoute(
        path: '/recipes/:id',
        name: 'recipe-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RecipeDetailScreen(recipeId: id);
        },
      ),
      GoRoute(
        path: '/ingredients',
        name: 'ingredients',
        builder: (context, state) => const IngredientsScreen(),
      ),
      GoRoute(
        path: '/pantry',
        name: 'pantry',
        builder: (context, state) => const PantryScreen(),
      ),
      GoRoute(
        path: '/meal-plan',
        name: 'meal-plan',
        builder: (context, state) => const MealPlanScreen(),
      ),
      GoRoute(
        path: '/filter-recipes',
        name: 'filter-recipes',
        builder: (context, state) => const FilterRecipesScreen(),
      ),
    ],
  );
}
