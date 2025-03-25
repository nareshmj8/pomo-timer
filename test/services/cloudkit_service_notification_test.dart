import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/cloudkit_service.dart';

// Extended CloudKitService for testing
class CloudKitServiceTester extends CloudKitService {
  bool get isInitialized => super.isInitialized;
  bool get isAvailable => super.isAvailable;

  // Stream controller for testing data changes
  final StreamController<void> _testDataChangedController =
      StreamController<void>.broadcast();

  @override
  Stream<void> get dataChangedStream => _testDataChangedController.stream;

  // Simulate platform method calls
  void simulateMethodCall(MethodCall call) async {
    if (call.method == 'onAvailabilityChanged') {
      final args = call.arguments as Map<dynamic, dynamic>;
      final available = args['available'] as bool;
      updateAvailability(available);
    } else if (call.method == 'onICloudAccountChanged') {
      final args = call.arguments as Map<dynamic, dynamic>;
      final available = args['available'] as bool;
      updateAvailability(available);
    } else if (call.method == 'onDataChanged') {
      // Emit event directly on our test stream controller
      _testDataChangedController.add(null);
    }
  }

  @override
  void dispose() {
    _testDataChangedController.close();
    super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channelName = 'com.naresh.pomodorotimemaster/cloudkit';

  group('CloudKitService Notifications', () {
    late CloudKitServiceTester service;

    setUp(() {
      service = CloudKitServiceTester();

      // Set up method channel mocking
      const channel = MethodChannel(channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        // Default successful responses
        if (call.method == 'isICloudAvailable') return true;
        if (call.method == 'subscribeToChanges') return true;
        if (call.method == 'processPendingOperations') return true;
        return null;
      });
    });

    tearDown(() {
      // Reset mock
      const channel = MethodChannel(channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      // Dispose service
      service.dispose();
    });

    test('notifies listeners when availability changes', () async {
      // Initialize
      await service.initialize();

      int notifiedCount = 0;
      service.addListener(() {
        notifiedCount++;
      });

      // Reset counter after initialization notifications
      notifiedCount = 0;

      // Act - update availability
      service.updateAvailability(false);

      // Assert
      expect(notifiedCount, 1);
      expect(service.isAvailable, false);
    });

    test('does not notify when availability stays the same', () async {
      // Initialize
      await service.initialize();

      int notifiedCount = 0;
      service.addListener(() {
        notifiedCount++;
      });

      // Reset counter after initialization notifications
      notifiedCount = 0;

      // Act - update with same value
      service.updateAvailability(true); // already true from initialization

      // Assert
      expect(notifiedCount, 0);
    });

    test('notifies via stream when availability changes', () async {
      // Initialize
      await service.initialize();

      // Set up listener
      final receivedValues = <bool>[];
      final completer = Completer<void>();
      var count = 0;

      final subscription = service.availabilityStream.listen((value) {
        receivedValues.add(value);
        count++;
        if (count >= 2) completer.complete();
      });

      // Act - simulate method calls
      service.simulateMethodCall(
          MethodCall('onAvailabilityChanged', {'available': false}));
      service.simulateMethodCall(
          MethodCall('onAvailabilityChanged', {'available': true}));

      // Wait for events to be processed
      await completer.future
          .timeout(const Duration(seconds: 1), onTimeout: () => null);

      // Clean up
      await subscription.cancel();

      // Assert
      expect(receivedValues, [false, true]);
    });

    test('notifies via stream when data changes', () async {
      // Initialize
      await service.initialize();

      // Set up listener
      int dataChangeCount = 0;
      final completer = Completer<void>();

      final subscription = service.dataChangedStream.listen((_) {
        dataChangeCount++;
        completer.complete();
      });

      // Act - simulate method call
      service.simulateMethodCall(MethodCall('onDataChanged'));

      // Wait for events to be processed
      await completer.future
          .timeout(const Duration(seconds: 1), onTimeout: () => null);

      // Clean up
      await subscription.cancel();

      // Assert
      expect(dataChangeCount, 1);
    });

    test('properly handles multiple availability changes', () async {
      // Initialize
      await service.initialize();

      // Set up listener
      final receivedValues = <bool>[];
      final completer = Completer<void>();
      var count = 0;

      final subscription = service.availabilityStream.listen((value) {
        receivedValues.add(value);
        count++;
        if (count >= 5) completer.complete();
      });

      // Act - simulate multiple method calls
      service.simulateMethodCall(
          MethodCall('onAvailabilityChanged', {'available': false}));
      service.simulateMethodCall(
          MethodCall('onAvailabilityChanged', {'available': true}));
      service.simulateMethodCall(
          MethodCall('onAvailabilityChanged', {'available': false}));
      service.simulateMethodCall(
          MethodCall('onAvailabilityChanged', {'available': true}));
      service.simulateMethodCall(
          MethodCall('onAvailabilityChanged', {'available': false}));

      // Wait for events to be processed
      await completer.future
          .timeout(const Duration(seconds: 1), onTimeout: () => null);

      // Clean up
      await subscription.cancel();

      // Assert
      expect(receivedValues, [false, true, false, true, false]);
      expect(service.isAvailable, false);
    });

    test('handles stream subscription cancellation', () async {
      // Initialize
      await service.initialize();

      // Set up listener
      int dataChangeCount = 0;
      final completer = Completer<void>();

      final subscription = service.dataChangedStream.listen((_) {
        dataChangeCount++;
        completer.complete();
      });

      // Simulate first change
      service.simulateMethodCall(MethodCall('onDataChanged'));

      // Wait for first event
      await completer.future
          .timeout(const Duration(seconds: 1), onTimeout: () => null);

      // Cancel subscription
      await subscription.cancel();

      // Simulate second change which should not be received
      service.simulateMethodCall(MethodCall('onDataChanged'));

      // Give time for potential events
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - only one notification received before cancellation
      expect(dataChangeCount, 1);
    });
  });
}
