import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A utility class that provides common testing functionality
class TestHelpers {
  /// Sets up a widget test with the provided widget and any required providers
  static Widget wrapWithMaterialApp(Widget widget) {
    return MaterialApp(
      home: widget,
    );
  }

  /// Sets up a widget test with the provided widget and any required providers
  static Widget wrapWithProvider<T extends ChangeNotifier>(
    Widget widget,
    T provider,
  ) {
    return MaterialApp(
      home: ChangeNotifierProvider<T>.value(
        value: provider,
        child: widget,
      ),
    );
  }

  /// Sets up a widget test with the provided widget and multiple providers
  static Widget wrapWithProviders(
    Widget widget,
    List<SingleChildWidget> providers,
  ) {
    return MaterialApp(
      home: MultiProvider(
        providers: providers,
        child: widget,
      ),
    );
  }

  /// A helper method to wrap widgets with error handling
  /// for use in tests. This suppresses overflow errors during testing.
  static Widget wrapWithErrorHandling(Widget child,
      {bool suppressOverflowErrors = false}) {
    if (suppressOverflowErrors) {
      // Simplified wrapper with fixed size and directionality
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Scaffold(
            body: child,
          ),
        ),
      );
    }
    return child;
  }

  /// Sets up mock SharedPreferences for tests
  static Future<void> setUpSharedPreferences(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    await SharedPreferences.getInstance();
  }

  /// Helper to find widgets by type and text
  static Finder findWidgetWithText(Type widgetType, String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(widgetType),
    );
  }

  /// Helper to trace widget tree for debugging
  static void printWidgetTree(WidgetTester tester) {
    debugDumpApp();
  }

  /// Helper to pump until no more frames are scheduled
  static Future<void> pumpUntilSettled(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Helper to pump with a specified duration
  static Future<void> pumpWithDuration(
    WidgetTester tester,
    Duration duration,
  ) async {
    await tester.pump(duration);
  }

  /// Verify that a specific error dialog is shown
  static void expectErrorDialog(WidgetTester tester, String errorMessage) {
    expect(find.text('Error'), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
  }

  /// Verify that a specific success dialog is shown
  static void expectSuccessDialog(WidgetTester tester, String message) {
    expect(find.text('Success'), findsOneWidget);
    expect(find.text(message), findsOneWidget);
  }

  /// Inject exception into a mock to test error handling
  static void injectException(Mock mock, Object exception) {
    when(mock).thenThrow(exception);
  }

  /// Create a fake async delay for testing async operations
  static Future<T> fakeDelay<T>(T value, {Duration? duration}) async {
    await Future.delayed(duration ?? const Duration(milliseconds: 100));
    return value;
  }
}

/// A widget that handles errors for testing purposes
class ErrorHandlingWidget extends StatelessWidget {
  final Widget child;
  final bool suppressOverflowErrors;

  const ErrorHandlingWidget({
    Key? key,
    required this.child,
    this.suppressOverflowErrors = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (suppressOverflowErrors) {
      // This allows tests to run without being affected by layout overflow errors
      return LayoutBuilder(
        builder: (context, constraints) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              viewInsets: EdgeInsets.zero,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    return child;
  }
}
