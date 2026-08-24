class LoggedWorkout {
  const LoggedWorkout({
    required this.id,
    required this.calories,
    required this.pointsAwarded,
    required this.capped,
  });

  final String id;
  final int calories;
  final int pointsAwarded;
  final bool capped;
}
