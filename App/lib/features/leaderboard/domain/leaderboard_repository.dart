import 'package:fitness_application/core/network/api_client.dart';

import 'weekly_leaderboard.dart';

abstract interface class LeaderboardRepository {
  Future<ApiResult<WeeklyLeaderboard>> fetchWeekly();
}
