import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timemaster/animations/confetti_animation.dart';
import 'package:confetti/confetti.dart';

void main() {
  group('ConfettiAnimation', () {
    late ConfettiAnimation confettiAnimation;

    setUp(() {
      confettiAnimation = ConfettiAnimation();
    });

    tearDown(() {
      confettiAnimation.dispose();
    });

    test('should initialize with medium intensity by default', () {
      expect(confettiAnimation.intensity, equals(ConfettiIntensity.medium));
    });

    test('should initialize with specified intensity', () {
      final lowIntensity = ConfettiAnimation(intensity: ConfettiIntensity.low);
      final highIntensity =
          ConfettiAnimation(intensity: ConfettiIntensity.high);

      expect(lowIntensity.intensity, equals(ConfettiIntensity.low));
      expect(highIntensity.intensity, equals(ConfettiIntensity.high));

      lowIntensity.dispose();
      highIntensity.dispose();
    });

    test('should return correct emission frequency based on intensity', () {
      final lowIntensity = ConfettiAnimation(intensity: ConfettiIntensity.low);
      final mediumIntensity =
          ConfettiAnimation(intensity: ConfettiIntensity.medium);
      final highIntensity =
          ConfettiAnimation(intensity: ConfettiIntensity.high);

      expect(lowIntensity.getEmissionFrequency(), equals(0.05));
      expect(mediumIntensity.getEmissionFrequency(), equals(0.1));
      expect(highIntensity.getEmissionFrequency(), equals(0.3));

      lowIntensity.dispose();
      mediumIntensity.dispose();
      highIntensity.dispose();
    });

    test('should return correct number of particles based on intensity', () {
      final lowIntensity = ConfettiAnimation(intensity: ConfettiIntensity.low);
      final mediumIntensity =
          ConfettiAnimation(intensity: ConfettiIntensity.medium);
      final highIntensity =
          ConfettiAnimation(intensity: ConfettiIntensity.high);

      expect(lowIntensity.getNumberOfParticles(), equals(10));
      expect(mediumIntensity.getNumberOfParticles(), equals(30));
      expect(highIntensity.getNumberOfParticles(), equals(50));

      lowIntensity.dispose();
      mediumIntensity.dispose();
      highIntensity.dispose();
    });

    test('should return correct blast force based on intensity', () {
      final lowIntensity = ConfettiAnimation(intensity: ConfettiIntensity.low);
      final mediumIntensity =
          ConfettiAnimation(intensity: ConfettiIntensity.medium);
      final highIntensity =
          ConfettiAnimation(intensity: ConfettiIntensity.high);

      expect(lowIntensity.getMaxBlastForce(), equals(20));
      expect(mediumIntensity.getMaxBlastForce(), equals(30));
      expect(highIntensity.getMaxBlastForce(), equals(40));

      expect(lowIntensity.getMinBlastForce(), equals(5));
      expect(mediumIntensity.getMinBlastForce(), equals(10));
      expect(highIntensity.getMinBlastForce(), equals(20));

      lowIntensity.dispose();
      mediumIntensity.dispose();
      highIntensity.dispose();
    });

    testWidgets('should build confetti widget correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: confettiAnimation.buildConfettiWidget(
            child: const Text('Test'),
          ),
        ),
      );

      // Verify the child widget is rendered
      expect(find.text('Test'), findsOneWidget);

      // Verify the ConfettiWidget is rendered
      expect(find.byType(ConfettiWidget), findsOneWidget);
    });

    testWidgets('should play and stop confetti animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: confettiAnimation.buildConfettiWidget(
            child: const Text('Test'),
          ),
        ),
      );

      // Initially, the confetti should not be playing
      final ConfettiWidget confettiWidget =
          tester.widget(find.byType(ConfettiWidget));
      expect(confettiWidget.confettiController.state,
          equals(ConfettiControllerState.stopped));

      // Play the animation
      confettiAnimation.play();
      await tester.pump();
      expect(confettiWidget.confettiController.state,
          equals(ConfettiControllerState.playing));

      // Stop the animation
      confettiAnimation.stop();
      await tester.pump();
      expect(confettiWidget.confettiController.state,
          equals(ConfettiControllerState.stopped));
    });
  });
}
