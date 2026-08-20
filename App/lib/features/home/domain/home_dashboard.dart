class HomeDashboard {
  HomeDashboard({
    required this.profile,
    required this.todayPlan,
    required List<WorkoutSummary> popularWorkouts,
  }) : popularWorkouts = List.unmodifiable(popularWorkouts);

  final HomeProfile profile;
  final WorkoutSummary? todayPlan;
  final List<WorkoutSummary> popularWorkouts;
}

class HomeProfile {
  const HomeProfile({
    required this.displayName,
    required this.email,
    required this.lifetimePoints,
    required this.availablePoints,
    required this.currentStreak,
  });

  final String displayName;
  final String email;
  final int lifetimePoints;
  final int availablePoints;
  final int currentStreak;
}

class WorkoutSummary {
  const WorkoutSummary({
    required this.slug,
    required this.name,
    required this.description,
    required this.workoutType,
    required this.durationMinutes,
    required this.estimatedCalories,
    required this.imageUrl,
  });

  final String slug;
  final String name;
  final String description;
  final String workoutType;
  final int durationMinutes;
  final int estimatedCalories;
  final String? imageUrl;
}
