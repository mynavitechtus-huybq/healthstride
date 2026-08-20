import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/home/domain/home_dashboard.dart';

abstract interface class HomeRepository {
  Future<ApiResult<HomeDashboard>> fetchDashboard();
}
