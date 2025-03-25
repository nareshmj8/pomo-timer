import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'notification_test_app.dart';
import 'package:pomodoro_timemaster/services/logging_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data at app startup
  try {
    tz_data.initializeTimeZones();
    debugPrint('🌍 Main: Timezone data initialized successfully');
  } catch (e) {
    debugPrint('🌍 Main: Error initializing timezone data: $e');
  }

  // Set error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('🔴 Flutter Error: ${details.exception}');
    debugPrint('🔴 Stack trace: ${details.stack}');

    // Log error to analytics and logging service
    LoggingService.logError(
      'Flutter Error',
      details.exception.toString(),
      details.stack,
    );

    FlutterError.presentError(details);
  };

  // Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 Platform Error: $error');
    debugPrint('🔴 Stack trace: $stack');

    // Log to our logging service
    LoggingService.logError(
      'Platform Error',
      error.toString(),
      stack,
    );

    // Return true to prevent the error from propagating
    return true;
  };

  // Run the app with error boundary
  runApp(const ErrorBoundary(child: NotificationTestApp()));
}

// Error boundary widget to capture errors in the widget tree
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  dynamic _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Show friendly error UI
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unexpected Error',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We\'re sorry, but something went wrong. The error has been reported and we\'re working on fixing it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Reset the error state and try again
                      setState(() {
                        _hasError = false;
                        _error = null;
                        _stackTrace = null;
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Debug Information:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: SingleChildScrollView(
                              child: Text(
                                _stackTrace.toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // If no error, return the app and set up the error handler
    return Builder(
      builder: (context) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          // Log the error
          LoggingService.logError(
            'Widget Error',
            errorDetails.exception.toString(),
            errorDetails.stack,
          );

          // Set the error state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _hasError = true;
              _error = errorDetails.exception;
              _stackTrace = errorDetails.stack;
            });
          });

          // Return an empty container
          return Container();
        };

        return widget.child;
      },
    );
  }
}
