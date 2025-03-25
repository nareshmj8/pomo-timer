import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/services/payment_sheet_handler.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Mock classes
class MockPackage extends Mock implements Package {
  @override
  String get identifier => 'test_package';
  
  @override
  StoreProduct get storeProduct => MockStoreProduct();
}

class MockStoreProduct extends Mock implements StoreProduct {
  @override
  String get identifier => 'test_product';
  
  @override
  String get priceString => '$9.99';
}

class MockConnectivity extends Mock implements Connectivity {
  ConnectivityResult _result = ConnectivityResult.wifi;
  
  void setConnectivityResult(ConnectivityResult result) {
    _result = result;
  }
  
  @override
  Future<ConnectivityResult> checkConnectivity() async {
    return _result;
  }
}

void main() {
  group('PaymentSheetHandler Tests', () {
    late MockPackage mockPackage;
    late MockConnectivity mockConnectivity;
    
    setUp(() {
      mockPackage = MockPackage();
      mockConnectivity = MockConnectivity();
    });
    
    testWidgets('Should detect network connectivity issues', 
        (WidgetTester tester) async {
      // Build a test app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    // Set connectivity to none before test
                    mockConnectivity.setConnectivityResult(ConnectivityResult.none);
                    
                    // Attempt to present payment sheet
                    final result = await PaymentSheetHandler.presentPaymentSheet(
                      context: context,
                      package: mockPackage,
                      showErrorDialog: false, // Avoid showing dialog in tests
                    );
                    
                    // Verify result
                    expect(result, equals(PaymentSheetStatus.failedToPresent));
                  },
                  child: const Text('Purchase'),
                );
              },
            ),
          ),
        ),
      );
      
      // Trigger the purchase
      await tester.tap(find.text('Purchase'));
      await tester.pump();
      
      // Verify payment sheet status is updated correctly
      expect(PaymentSheetHandler.currentStatus, equals(PaymentSheetStatus.failedToPresent));
    });
    
    testWidgets('Should handle payment sheet timeout properly', 
        (WidgetTester tester) async {
      // Build a test app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    // Set connectivity to wifi for this test
                    mockConnectivity.setConnectivityResult(ConnectivityResult.wifi);
                    
                    // Start timeout timer but don't complete the purchase
                    PaymentSheetHandler._startTimeoutTimer(context);
                    PaymentSheetHandler._currentStatus = PaymentSheetStatus.preparing;
                    
                    // Fast forward time to trigger timeout
                    await tester.pump(const Duration(seconds: 11));
                    
                    // Verify timeout was handled
                    expect(PaymentSheetHandler.currentStatus, 
                           equals(PaymentSheetStatus.failedToPresent));
                  },
                  child: const Text('Purchase'),
                );
              },
            ),
          ),
        ),
      );
      
      // Trigger the purchase
      await tester.tap(find.text('Purchase'));
      await tester.pump();
      
      // Verify dialog is shown after timeout
      await tester.pump(const Duration(seconds: 11));
      expect(find.text('Purchase Problem'), findsOneWidget);
    });
    
    test('Should reset state correctly', () {
      // Setup initial state
      PaymentSheetHandler._currentStatus = PaymentSheetStatus.preparing;
      
      // Call reset
      PaymentSheetHandler._resetState();
      
      // Verify state is reset
      expect(PaymentSheetHandler.currentStatus, equals(PaymentSheetStatus.notShown));
    });
  });
} 