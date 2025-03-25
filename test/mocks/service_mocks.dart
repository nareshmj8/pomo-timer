import 'package:mockito/annotations.dart';
import 'package:pomodoro_timemaster/services/analytics_service.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:pomodoro_timemaster/services/notification_service.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';
import 'package:pomodoro_timemaster/services/sync_service.dart';
import 'package:pomodoro_timemaster/services/timer_service.dart';

/// This file generates mock classes for our services
/// Run the following command to generate the mocks:
/// flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  AnalyticsService,
  CloudKitService,
  NotificationService,
  RevenueCatService,
  SyncService,
  TimerService,
])
void main() {
  // This is empty on purpose
  // The main function is required for the build_runner to generate the mocks
}
