import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/home/domain/home_dashboard.dart';
import 'package:fitness_application/features/home/domain/home_repository.dart';
import 'package:flutter/foundation.dart';

class HomeController extends ValueNotifier<HomeViewState> {
  HomeController({required this.repository}) : super(const HomeViewState());

  final HomeRepository repository;
  var _requestGeneration = 0;
  var _isDisposed = false;

  Future<void> load() async {
    if (_isDisposed) return;
    final requestGeneration = ++_requestGeneration;
    final currentState = value;
    if (currentState.dashboard == null) {
      value = currentState.copyWith(failure: null, isInitialLoading: true);
    } else if (currentState.failure != null) {
      value = currentState.copyWith(failure: null);
    }
    if (!_canPublish(requestGeneration)) return;

    final result = await repository.fetchDashboard();
    _publishResult(
      result,
      requestGeneration: requestGeneration,
      fallbackDashboard: currentState.dashboard,
    );
  }

  Future<void> refresh() async {
    if (_isDisposed) return;
    if (value.dashboard == null) return load();

    final requestGeneration = ++_requestGeneration;
    final currentState = value;
    value = currentState.copyWith(failure: null, isRefreshing: true);
    if (!_canPublish(requestGeneration)) return;

    final result = await repository.fetchDashboard();
    _publishResult(
      result,
      requestGeneration: requestGeneration,
      fallbackDashboard: currentState.dashboard,
    );
  }

  Future<void> retry() => load();

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _requestGeneration += 1;
    super.dispose();
  }

  void _publishResult(
    ApiResult<HomeDashboard> result, {
    required int requestGeneration,
    required HomeDashboard? fallbackDashboard,
  }) {
    if (!_canPublish(requestGeneration)) return;

    if (result.data != null) {
      value = HomeViewState(dashboard: result.data);
      return;
    }

    value = HomeViewState(
      dashboard: fallbackDashboard,
      failure: result.failure,
    );
  }

  bool _canPublish(int requestGeneration) {
    return !_isDisposed && requestGeneration == _requestGeneration;
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
