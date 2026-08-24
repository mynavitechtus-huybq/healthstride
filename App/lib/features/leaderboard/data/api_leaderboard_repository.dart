import 'package:fitness_application/core/network/api_client.dart';

import '../domain/leaderboard_repository.dart';
import '../domain/weekly_leaderboard.dart';

class ApiLeaderboardRepository implements LeaderboardRepository {
  const ApiLeaderboardRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiResult<WeeklyLeaderboard>> fetchWeekly() async {
    try {
      return await _apiClient.get(
        '/v1/leaderboards/weekly',
        _decodeLeaderboard,
      );
    } on FormatException {
      return _invalidResponse();
    } on TypeError {
      return _invalidResponse();
    }
  }

  WeeklyLeaderboard _decodeLeaderboard(Map<String, dynamic> json) {
    final weekStart = json['week_start'];
    final currentUserRank = json['current_user_rank'];
    final rawRows = json['rows'];
    if (weekStart is! String ||
        (currentUserRank != null && currentUserRank is! int) ||
        rawRows is! List<dynamic>) {
      throw const FormatException('Invalid leaderboard payload');
    }

    return WeeklyLeaderboard(
      weekStart: weekStart,
      currentUserRank: currentUserRank as int?,
      rows: rawRows.map(_decodeRow).toList(growable: false),
    );
  }

  LeaderboardRow _decodeRow(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid leaderboard row');
    }

    final rank = value['rank'];
    final userId = value['user_id'];
    final displayName = value['display_name'];
    final points = value['points'];
    if (rank is! int ||
        userId is! String ||
        displayName is! String ||
        points is! int) {
      throw const FormatException('Invalid leaderboard row');
    }

    return LeaderboardRow(
      rank: rank,
      userId: userId,
      displayName: displayName,
      points: points,
    );
  }

  ApiResult<WeeklyLeaderboard> _invalidResponse() {
    return const ApiResult.failure(
      ApiFailure(code: 'INVALID_RESPONSE', message: 'Invalid API response.'),
    );
  }
}
