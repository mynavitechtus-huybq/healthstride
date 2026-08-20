import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/home/domain/home_dashboard.dart';
import 'package:fitness_application/features/home/domain/home_repository.dart';

class ApiHomeRepository implements HomeRepository {
  const ApiHomeRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiResult<HomeDashboard>> fetchDashboard() async {
    try {
      return await _apiClient.get('/v1/home', _decodeDashboard);
    } on FormatException {
      return _invalidResponse();
    } on TypeError {
      return _invalidResponse();
    }
  }

  HomeDashboard _decodeDashboard(Map<String, dynamic> json) {
    return HomeDashboard(
      profile: _decodeProfile(_map(json, 'profile')),
      todayPlan: _decodeNullableWorkout(json['today_plan']),
      popularWorkouts: _decodePopularWorkouts(json['popular_workouts']),
    );
  }

  HomeProfile _decodeProfile(Map<String, dynamic> json) {
    return HomeProfile(
      displayName: _string(json, 'display_name'),
      email: _string(json, 'email'),
      lifetimePoints: _int(json, 'lifetime_points'),
      availablePoints: _int(json, 'available_points'),
      currentStreak: _int(json, 'current_streak'),
    );
  }

  WorkoutSummary? _decodeNullableWorkout(Object? json) {
    if (json == null) return null;
    if (json is! Map<String, dynamic>) throw const FormatException();
    return _decodeWorkout(json);
  }

  List<WorkoutSummary> _decodePopularWorkouts(Object? json) {
    if (json is! List<Object?>) throw const FormatException();
    return json
        .map((item) {
          if (item is! Map<String, dynamic>) throw const FormatException();
          return _decodeWorkout(item);
        })
        .toList(growable: false);
  }

  WorkoutSummary _decodeWorkout(Map<String, dynamic> json) {
    return WorkoutSummary(
      slug: _string(json, 'slug'),
      name: _string(json, 'name'),
      description: _string(json, 'description'),
      workoutType: _string(json, 'workout_type'),
      durationMinutes: _int(json, 'duration_minutes'),
      estimatedCalories: _int(json, 'estimated_calories'),
      imageUrl: _nullableString(json, 'image_url'),
    );
  }

  Map<String, dynamic> _map(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    throw const FormatException();
  }

  String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw const FormatException();
  }

  String? _nullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null || value is String) return value;
    throw const FormatException();
  }

  int _int(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    throw const FormatException();
  }

  ApiResult<HomeDashboard> _invalidResponse() {
    return const ApiResult.failure(
      ApiFailure(code: 'INVALID_RESPONSE', message: 'Invalid API response.'),
    );
  }
}
