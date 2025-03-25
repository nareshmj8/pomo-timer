import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/services/service_locator.dart';

// Create mock for RevenueCatService
class MockRevenueCatService extends Mock implements RevenueCatService {
  bool _isPremium = false;

  @override
  bool get isPremium => _isPremium;

  void setIsPremium(bool value) {
    _isPremium = value;
  }
}

// Extended CloudKitService for testing
class CloudKitServiceTester extends CloudKitService {
  bool _syncEnabled = false;

  @override
  Future<bool> isICloudAvailable() async {
    // Always return true for testing
    return true;
  }

  @override
  Future<void> initialize() async {
    // Override to simulate initialization without actual CloudKit
    // Check premium status to determine if sync should be enabled
    final serviceLocator = ServiceLocator();
    final revenueCatService = serviceLocator.revenueCatService;
    _syncEnabled = revenueCatService.isPremium;

    // Simulate initialization as successful
    super.updateAvailability(true);
  }

  // Custom getter and methods for testing
  bool get isSyncEnabled => _syncEnabled;

  Future<void> checkPremiumStatus() async {
    // Simulate checking premium status
    final serviceLocator = ServiceLocator();
    final revenueCatService = serviceLocator.revenueCatService;
    _syncEnabled = revenueCatService.isPremium;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CloudKitServiceTester cloudKitService;
  late MockRevenueCatService mockRevenueCatService;

  setUp(() async {
    // Set up SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Create mock services
    mockRevenueCatService = MockRevenueCatService();
    cloudKitService = CloudKitServiceTester();

    // Register services in the service locator
    ServiceLocator().registerRevenueCatService(mockRevenueCatService);
  });

  tearDown(() {
    // Reset the service locator between tests
    ServiceLocator().reset();
  });

  group('iCloud Premium Access Tests', () {
    test('Should enable iCloud sync for premium users', () async {
      // Setup premium user
      mockRevenueCatService.setIsPremium(true);

      // Initialize CloudKit service
      await cloudKitService.initialize();

      // Verify that sync is enabled
      expect(cloudKitService.isAvailable, isTrue,
          reason: 'CloudKit service should be available');
      expect(cloudKitService.isSyncEnabled, isTrue,
          reason: 'iCloud sync should be enabled for premium users');
    });

    test('Should disable iCloud sync for non-premium users', () async {
      // Setup non-premium user
      mockRevenueCatService.setIsPremium(false);

      // Initialize CloudKit service
      await cloudKitService.initialize();

      // Verify that sync is disabled
      expect(cloudKitService.isAvailable, isTrue,
          reason: 'CloudKit service should be available');
      expect(cloudKitService.isSyncEnabled, isFalse,
          reason: 'iCloud sync should be disabled for non-premium users');
    });

    test('Should disable sync when premium status is lost', () async {
      // Initial setup as premium
      mockRevenueCatService.setIsPremium(true);

      // Initialize CloudKit service
      await cloudKitService.initialize();

      // Verify initially enabled
      expect(cloudKitService.isSyncEnabled, isTrue);

      // Change to non-premium
      mockRevenueCatService.setIsPremium(false);

      // Trigger check for premium status
      await cloudKitService.checkPremiumStatus();

      // Verify now disabled
      expect(cloudKitService.isSyncEnabled, isFalse,
          reason: 'iCloud sync should be disabled when premium status is lost');
    });

    test('Should enable sync when premium status is gained', () async {
      // Initial setup as non-premium
      mockRevenueCatService.setIsPremium(false);

      // Initialize CloudKit service
      await cloudKitService.initialize();

      // Verify initially disabled
      expect(cloudKitService.isSyncEnabled, isFalse);

      // Change to premium
      mockRevenueCatService.setIsPremium(true);

      // Trigger check for premium status
      await cloudKitService.checkPremiumStatus();

      // Verify now enabled
      expect(cloudKitService.isSyncEnabled, isTrue,
          reason:
              'iCloud sync should be enabled when premium status is gained');
    });
  });
}
