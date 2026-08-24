import 'package:fitness_application/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

import '../domain/leaderboard_repository.dart';
import '../domain/weekly_leaderboard.dart';

class LeaderboardController extends ValueNotifier<LeaderboardViewState> {
  LeaderboardController({required this.repository})
    : super(const LeaderboardViewState());

  final LeaderboardRepository repository;
  var _requestGeneration = 0;
  var _isDisposed = false;

  Future<void> load() async {
    if (_isDisposed) return;
    final generation = ++_requestGeneration;
    value = value.copyWith(failure: null, isLoading: true);
    final result = await repository.fetchWeekly();
    if (!_canPublish(generation)) return;
    value = result.data == null
        ? LeaderboardViewState(failure: result.failure)
        : LeaderboardViewState(leaderboard: result.data);
  }

  Future<void> retry() => load();

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _requestGeneration += 1;
    super.dispose();
  }

  bool _canPublish(int generation) =>
      !_isDisposed && generation == _requestGeneration;
}

class LeaderboardViewState {
  const LeaderboardViewState({
    this.leaderboard,
    this.failure,
    this.isLoading = false,
  });

  final WeeklyLeaderboard? leaderboard;
  final ApiFailure? failure;
  final bool isLoading;

  LeaderboardViewState copyWith({
    Object? leaderboard = _sentinel,
    Object? failure = _sentinel,
    bool? isLoading,
  }) {
    return LeaderboardViewState(
      leaderboard: identical(leaderboard, _sentinel)
          ? this.leaderboard
          : leaderboard as WeeklyLeaderboard?,
      failure: identical(failure, _sentinel)
          ? this.failure
          : failure as ApiFailure?,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

const Object _sentinel = Object();
