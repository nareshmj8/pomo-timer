import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pomodoro_timemaster/screens/splash_screen.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';

class MockNavigatorObserver extends NavigatorObserver {
  List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

void main() {
  testWidgets('Splash screen appears correctly with logo and text',
      (WidgetTester tester) async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({
      'selectedTheme': 'Light',
    });
    final prefs = await SharedPreferences.getInstance();
    final settingsProvider = SettingsProvider(prefs);
    await settingsProvider.init();

    final mockObserver = MockNavigatorObserver();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => settingsProvider),
        ],
        child: CupertinoApp(
          theme: const CupertinoThemeData(
            brightness: Brightness.light,
            primaryColor: CupertinoColors.activeBlue,
          ),
          navigatorObservers: [mockObserver],
          builder: (context, child) {
            // Add a focus scope to properly handle focus throughout the app
            return FocusScope(
              autofocus: true,
              child: child!,
            );
          },
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const Placeholder(),
          },
        ),
      ),
    );

    // Verify splash screen appears without delay
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);

    // Verify Flutter logo is present in the splash screen
    expect(find.byType(Image), findsOneWidget);

    // Verify the logo is the correct asset
    final Image logoImage = tester.widget(find.byType(Image));
    expect((logoImage.image as AssetImage).assetName,
        equals('assets/appstore.png'));

    // Verify text elements are present
    expect(find.text('Pomodoro TimeMaster'), findsOneWidget);
    expect(find.text('Master Your Time, Master Your Life'), findsOneWidget);

    // Verify light theme is used in light mode
    final context = tester.element(find.byType(SplashScreen));
    final brightness = CupertinoTheme.of(context).brightness;
    expect(brightness, equals(Brightness.light));

    // Fast-forward animation to 50%
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify animations are in progress
    final fadeTransitions =
        tester.widgetList<FadeTransition>(find.byType(FadeTransition));
    expect(fadeTransitions.length, greaterThan(0));

    // Fast-forward to complete the timer
    await tester.pumpAndSettle(const Duration(milliseconds: 2100));

    // Verify navigation occurred
    expect(mockObserver.pushedRoutes.isNotEmpty, isTrue);
  });

  testWidgets('Splash screen uses dark theme in dark mode',
      (WidgetTester tester) async {
    // Set up SharedPreferences mock with dark theme
    SharedPreferences.setMockInitialValues({
      'selectedTheme': 'Dark',
    });
    final prefs = await SharedPreferences.getInstance();
    final settingsProvider = SettingsProvider(prefs);
    await settingsProvider.init();

    final mockObserver = MockNavigatorObserver();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => settingsProvider),
        ],
        child: CupertinoApp(
          theme: const CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: CupertinoColors.activeBlue,
          ),
          navigatorObservers: [mockObserver],
          builder: (context, child) {
            // Add a focus scope to properly handle focus throughout the app
            return FocusScope(
              autofocus: true,
              child: child!,
            );
          },
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const Placeholder(),
          },
        ),
      ),
    );

    // Verify splash screen appears
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);

    // Verify Flutter logo is present in the splash screen
    expect(find.byType(Image), findsOneWidget);

    // Verify the logo is the correct asset
    final Image logoImage = tester.widget(find.byType(Image));
    expect((logoImage.image as AssetImage).assetName,
        equals('assets/appstore.png'));

    // Verify dark theme is used in dark mode
    final context = tester.element(find.byType(SplashScreen));
    final brightness = CupertinoTheme.of(context).brightness;
    expect(brightness, equals(Brightness.dark));

    // Fast-forward to complete the timer
    await tester.pumpAndSettle(const Duration(milliseconds: 2100));

    // Verify navigation occurred
    expect(mockObserver.pushedRoutes.isNotEmpty, isTrue);
  });
}
