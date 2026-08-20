import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/home/domain/home_dashboard.dart';
import 'package:fitness_application/features/home/domain/home_repository.dart';
import 'package:flutter/foundation.dart';

class HomeController extends ValueNotifier<HomeViewState> {
  HomeController({required this.repository}) : super(const HomeViewState());

  final HomeRepository repository;

  Future<void> load() async {
    final currentState = value;
    if (currentState.dashboard == null) {
      value = currentState.copyWith(failure: null, isInitialLoading: true);
    } else if (currentState.failure != null) {
      value = currentState.copyWith(failure: null);
    }

    final result = await repository.fetchDashboard();
    _publishResult(result, fallbackDashboard: currentState.dashboard);
  }

  Future<void> refresh() async {
    if (value.dashboard == null) return load();

    final currentState = value;
    value = currentState.copyWith(failure: null, isRefreshing: true);

    final result = await repository.fetchDashboard();
    _publishResult(result, fallbackDashboard: currentState.dashboard);
  }

  Future<void> retry() => load();

  void _publishResult(
    ApiResult<HomeDashboard> result, {
    required HomeDashboard? fallbackDashboard,
  }) {
    if (result.data != null) {
      value = HomeViewState(dashboard: result.data);
      return;
    }

    value = HomeViewState(
      dashboard: fallbackDashboard,
      failure: result.failure,
    );
  }
}

class HomeViewState {
  const HomeViewState({
    this.dashboard,
    this.failure,
    this.isInitialLoading = false,
    this.isRefreshing = false,
  });

  final HomeDashboard? dashboard;
  final ApiFailure? failure;
  final bool isInitialLoading;
  final bool isRefreshing;

  HomeViewState copyWith({
    Object? dashboard = _sentinel,
    Object? failure = _sentinel,
    bool? isInitialLoading,
    bool? isRefreshing,
  }) {
    return HomeViewState(
      dashboard: identical(dashboard, _sentinel)
          ? this.dashboard
          : dashboard as HomeDashboard?,
      failure: identical(failure, _sentinel)
          ? this.failure
          : failure as ApiFailure?,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

const Object _sentinel = Object();
