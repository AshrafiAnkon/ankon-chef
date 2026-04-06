import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/meal_plan_service.dart';
import '../models/meal_plan_model.dart';
import 'auth_provider.dart';

part 'meal_plan_provider.g.dart';

/// Meal plan service provider
@riverpod
MealPlanService mealPlanService(Ref ref) {
  return MealPlanService();
}

/// All meal plans for current user
@riverpod
Stream<List<MealPlan>> mealPlans(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  final service = ref.watch(mealPlanServiceProvider);
  return service.getMealPlans(user.uid);
}

/// Meal plan for a specific date
@riverpod
Future<MealPlan?> mealPlanForDate(Ref ref, DateTime date) async {
  final allPlansAsync = ref.watch(mealPlansProvider);
  final allPlans = allPlansAsync.value ?? [];
  
  final targetDate = DateTime(date.year, date.month, date.day);
  try {
    return allPlans.firstWhere(
      (plan) => 
        plan.planDate.year == targetDate.year &&
        plan.planDate.month == targetDate.month &&
        plan.planDate.day == targetDate.day
    );
  } catch (_) {
    return null;
  }
}


