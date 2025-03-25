import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pomodoro_timemaster/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App starts up correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify the app has started and shows the main screen
      expect(find.byType(app.MyApp), findsOneWidget);
    });
  });
}
