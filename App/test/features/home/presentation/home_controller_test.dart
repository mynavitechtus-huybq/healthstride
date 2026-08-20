import 'dart:async';

import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/home/data/api_home_repository.dart';
import 'package:fitness_application/features/home/domain/home_dashboard.dart';
import 'package:fitness_application/features/home/domain/home_repository.dart';
import 'package:fitness_application/features/home/presentation/home_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'publishes initial loading before the first dashboard arrives',
    () async {
      final completer = Completer<ApiResult<HomeDashboard>>();
      final controller = HomeController(
        repository: _DeferredHomeRepository(completer.future),
      );

      final load = controller.load();

      expect(controller.value.isInitialLoading, isTrue);
      expect(controller.value.isRefreshing, isFalse);
      expect(controller.value.dashboard, isNull);
      expect(controller.value.failure, isNull);

      completer.complete(ApiResult.success(_sampleDashboard()));
      await load;

      expect(controller.value.isInitialLoading, isFalse);
      expect(controller.value.dashboard?.profile.displayName, 'Ari');
    },
  );

  test('keeps previous dashboard while refreshing', () async {
    final controller = HomeController(
      repository: _QueuedHomeRepository([
        ApiResult.success(_sampleDashboard()),
        ApiResult.success(
          _sampleDashboard(availablePoints: 95, planName: 'Recovery Walk'),
        ),
      ]),
    );

    await controller.load();

    final refresh = controller.refresh();

    expect(controller.value.dashboard?.profile.displayName, 'Ari');
    expect(controller.value.dashboard?.profile.availablePoints, 90);
    expect(controller.value.isRefreshing, isTrue);
    expect(controller.value.isInitialLoading, isFalse);

    await refresh;

    expect(controller.value.isRefreshing, isFalse);
    expect(controller.value.dashboard?.profile.availablePoints, 95);
    expect(controller.value.dashboard?.todayPlan?.name, 'Recovery Walk');
  });

  test('publishes a retryable initial failure', () async {
    final controller = HomeController(
      repository: _QueuedHomeRepository([
        const ApiResult.failure(
          ApiFailure(
            code: 'NETWORK_REQUEST_FAILED',
            message: 'Please try again.',
          ),
        ),
      ]),
    );

    await controller.load();

    expect(controller.value.failure?.code, 'NETWORK_REQUEST_FAILED');
    expect(controller.value.dashboard, isNull);
    expect(controller.value.isInitialLoading, isFalse);
    expect(controller.value.isRefreshing, isFalse);
  });

  test('leaves initial loading when API token lookup fails', () async {
    final controller = HomeController(
      repository: ApiHomeRepository(
        ApiClient(
          tokenProvider: () async => throw Exception('token lookup failed'),
          getRequest: (_, {required headers}) async => _successHomeResponse(),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.value.failure?.code, 'NETWORK_REQUEST_FAILED');
    expect(controller.value.dashboard, isNull);
    expect(controller.value.isInitialLoading, isFalse);
    expect(controller.value.isRefreshing, isFalse);
  });

  test('leaves refresh with stale data when the API request fails', () async {
    var requestCount = 0;
    final controller = HomeController(
      repository: ApiHomeRepository(
        ApiClient(
          tokenProvider: () async => 'firebase-token',
          getRequest: (_, {required headers}) async {
            requestCount += 1;
            if (requestCount == 1) return _successHomeResponse();
            throw Exception('socket failed');
          },
        ),
      ),
    );
    addTearDown(controller.dispose);

    await controller.load();
    await controller.refresh();

    expect(controller.value.failure?.code, 'NETWORK_REQUEST_FAILED');
    expect(controller.value.dashboard?.profile.displayName, 'Ari');
    expect(controller.value.isInitialLoading, isFalse);
    expect(controller.value.isRefreshing, isFalse);
  });

  test('retry reloads after an initial failure', () async {
    final controller = HomeController(
      repository: _QueuedHomeRepository([
        const ApiResult.failure(
          ApiFailure(
            code: 'NETWORK_REQUEST_FAILED',
            message: 'Please try again.',
          ),
        ),
        ApiResult.success(_sampleDashboard()),
      ]),
    );

    await controller.load();
    await controller.retry();

    expect(controller.value.failure, isNull);
    expect(controller.value.dashboard?.profile.displayName, 'Ari');
  });

  test('does not publish an initial load completion after dispose', () async {
    final completer = Completer<ApiResult<HomeDashboard>>();
    final controller = HomeController(
      repository: _DeferredHomeRepository(completer.future),
    );

    final load = controller.load();
    final stateAtDispose = controller.value;
    controller.dispose();
    completer.complete(ApiResult.success(_sampleDashboard()));

    await expectLater(load, completes);
    expect(identical(controller.value, stateAtDispose), isTrue);
  });

  test('does not publish a refresh completion after dispose', () async {
    final refreshCompleter = Completer<ApiResult<HomeDashboard>>();
    final controller = HomeController(
      repository: _QueuedFutureHomeRepository([
        Future.value(ApiResult.success(_sampleDashboard())),
        refreshCompleter.future,
      ]),
    );

    await controller.load();
    final refresh = controller.refresh();
    final stateAtDispose = controller.value;
    controller.dispose();
    refreshCompleter.complete(
      ApiResult.success(
        _sampleDashboard(availablePoints: 95, planName: 'Recovery Walk'),
      ),
    );

    await expectLater(refresh, completes);
    expect(identical(controller.value, stateAtDispose), isTrue);
    expect(controller.value.dashboard?.profile.availablePoints, 90);
  });

  test('ignores an older load completing after a newer refresh', () async {
    final olderLoad = Completer<ApiResult<HomeDashboard>>();
    final newerRefresh = Completer<ApiResult<HomeDashboard>>();
    final controller = HomeController(
      repository: _QueuedFutureHomeRepository([
        Future.value(ApiResult.success(_sampleDashboard())),
        olderLoad.future,
        newerRefresh.future,
      ]),
    );
    addTearDown(controller.dispose);

    await controller.load();
    final load = controller.load();
    final refresh = controller.refresh();

    expect(controller.value.dashboard?.profile.availablePoints, 90);
    expect(controller.value.isRefreshing, isTrue);

    newerRefresh.complete(
      ApiResult.success(
        _sampleDashboard(availablePoints: 110, planName: 'Tempo Run'),
      ),
    );
    await refresh;
    olderLoad.complete(
      ApiResult.success(
        _sampleDashboard(availablePoints: 95, planName: 'Recovery Walk'),
      ),
    );
    await load;

    expect(controller.value.dashboard?.profile.availablePoints, 110);
    expect(controller.value.dashboard?.todayPlan?.name, 'Tempo Run');
    expect(controller.value.isRefreshing, isFalse);
  });
}

ApiResponse _successHomeResponse() {
  return const ApiResponse(
    statusCode: 200,
    body: {
      'data': {
        'profile': {
          'display_name': 'Ari',
          'email': 'ari@example.com',
          'lifetime_points': 120,
          'available_points': 90,
          'current_streak': 3,
        },
        'today_plan': null,
        'popular_workouts': [],
      },
      'meta': {},
      'error': null,
    },
  );
}

class _DeferredHomeRepository implements HomeRepository {
  _DeferredHomeRepository(this.result);

  final Future<ApiResult<HomeDashboard>> result;

  @override
  Future<ApiResult<HomeDashboard>> fetchDashboard() => result;
}

class _QueuedFutureHomeRepository implements HomeRepository {
  _QueuedFutureHomeRepository(this._results);

  final List<Future<ApiResult<HomeDashboard>>> _results;
  var _index = 0;

  @override
  Future<ApiResult<HomeDashboard>> fetchDashboard() {
    final index = _index;
    _index += 1;
    return _results[index];
  }
}

class _QueuedHomeRepository implements HomeRepository {
  _QueuedHomeRepository(this._results);

  final List<ApiResult<HomeDashboard>> _results;
  var _index = 0;

  @override
  Future<ApiResult<HomeDashboard>> fetchDashboard() async {
    final index = _index;
    _index += 1;
    return _results[index];
  }
}

HomeDashboard _sampleDashboard({
  int availablePoints = 90,
  String planName = 'Morning Cardio',
}) {
  return HomeDashboard(
    profile: HomeProfile(
      displayName: 'Ari',
      email: 'ari@example.com',
      lifetimePoints: 120,
      availablePoints: availablePoints,
      currentStreak: 3,
    ),
    todayPlan: WorkoutSummary(
      slug: 'morning-cardio',
      name: planName,
      description: 'Start strong.',
      workoutType: 'cardio',
      durationMinutes: 30,
      estimatedCalories: 220,
      imageUrl: null,
    ),
    popularWorkouts: const [
      WorkoutSummary(
        slug: 'core-blast',
        name: 'Core Blast',
        description: 'Build endurance.',
        workoutType: 'strength',
        durationMinutes: 20,
        estimatedCalories: 180,
        imageUrl: null,
      ),
    ],
  );
}
