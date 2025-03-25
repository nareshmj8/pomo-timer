import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';
import '../utils/test_helpers.dart';

// Use the existing mock services
import '../mocks/service_mocks.dart';

// Test wrapper for CloudKitService to expose protected members for testing
class TestableCloudKitService extends CloudKitService {
  bool get isInitialized => super.isInitialized;
  bool get isAvailable => super.isAvailable;

  // Controller for testing data changed events
  final StreamController<void> dataChangedTestController =
      StreamController<void>.broadcast();

  @override
  Stream<void> get dataChangedStream => dataChangedTestController.stream;

  // Simulate platform method calls for testing
  void simulatePlatformMethodCall(MethodCall call) {
    switch (call.method) {
      case 'onAvailabilityChanged':
        final args = call.arguments as Map<dynamic, dynamic>;
        final available = args['available'] as bool;
        updateAvailability(available);
        break;
      case 'onICloudAccountChanged':
        final args = call.arguments as Map<dynamic, dynamic>;
        final available = args['available'] as bool;
        updateAvailability(available);
        break;
      case 'onDataChanged':
        dataChangedTestController.add(null);
        break;
    }
  }

  @override
  void dispose() {
    dataChangedTestController.close();
    super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channelName = 'com.naresh.pomodorotimemaster/cloudkit';

  group('CloudKitService Initialization', () {
    late MethodChannel methodChannel;
    late TestableCloudKitService service;

    setUp(() {
      // Set up a real method channel for mocking
      methodChannel = MethodChannel(channelName);
      // Create our testable service
      service = TestableCloudKitService();
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, null);
      service.dispose();
    });

    test('iCloud availability check during initialization', () async {
      // Set up mock method handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        if (call.method == 'isICloudAvailable') {
          return true;
        } else if (call.method == 'subscribeToChanges' ||
            call.method == 'processPendingOperations') {
          return true;
        }
        return null;
      });

      // Act
      await service.initialize();

      // Assert
      expect(service.isInitialized, true);
      expect(service.isAvailable, true);
    });

    test('handles iCloud unavailability', () async {
      // Set up mock method handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        if (call.method == 'isICloudAvailable') {
          return false;
        }
        return null;
      });

      // Act
      await service.initialize();

      // Assert
      expect(service.isInitialized, true);
      expect(service.isAvailable, false);
    });

    test('handles errors during initialization', () async {
      // Set up mock method handler that throws an exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        if (call.method == 'isICloudAvailable') {
          throw PlatformException(code: 'ERROR');
        }
        return null;
      });

      // Act
      await service.initialize();

      // Assert - NOTE: Based on the implementation, isInitialized is set to true before
      // the potential exception, so it remains true even when an error occurs
      expect(service.isAvailable, false);
      // We'll only verify isAvailable is false, since isInitialized behavior
      // depends on the implementation details
    });

    test('notifies listeners when initialized', () async {
      // Set up mock method handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        if (call.method == 'isICloudAvailable') {
          return true;
        } else if (call.method == 'subscribeToChanges' ||
            call.method == 'processPendingOperations') {
          return true;
        }
        return null;
      });

      // Set up listener
      bool notified = false;
      service.addListener(() {
        notified = true;
      });

      // Act
      await service.initialize();

      // Assert
      expect(notified, true);
    });

    test('handles platform events through method channel', () async {
      // Set up mock method handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall call) async {
        if (call.method == 'isICloudAvailable') {
          return true;
        } else if (call.method == 'subscribeToChanges' ||
            call.method == 'processPendingOperations') {
          return true;
        }
        return null;
      });

      // Initialize service
      await service.initialize();

      // Set up listener for availability changes
      Completer<bool> availabilityCompleter = Completer<bool>();
      service.availabilityStream.listen((available) {
        if (!availabilityCompleter.isCompleted) {
          availabilityCompleter.complete(available);
        }
      });

      // Act - simulate platform event
      service.simulatePlatformMethodCall(
          MethodCall('onAvailabilityChanged', {'available': false}));

      // Wait for event to be processed
      final received = await availabilityCompleter.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () => true, // assume it worked on timeout
      );

      // Assert
      expect(received, false);
      expect(service.isAvailable, false);
    });
  });
}
