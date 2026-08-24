class WeeklyLeaderboard {
  const WeeklyLeaderboard({
    required this.weekStart,
    required this.rows,
    required this.currentUserRank,
  });

  final String weekStart;
  final List<LeaderboardRow> rows;
  final int? currentUserRank;
}

class LeaderboardRow {
  const LeaderboardRow({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.points,
  });

  final int rank;
  final String userId;
  final String displayName;
  final int points;
}
