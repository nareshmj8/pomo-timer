import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

enum ConfettiIntensity {
  low,
  medium,
  high,
}

class ConfettiAnimation {
  late ConfettiController _confettiController;
  final ConfettiIntensity intensity;

  ConfettiAnimation({this.intensity = ConfettiIntensity.medium}) {
    _confettiController = ConfettiController(
      duration: Duration(seconds: intensity == ConfettiIntensity.high ? 10 : 5),
    );
  }

  ConfettiController get controller => _confettiController;

  void play() {
    _confettiController.play();
  }

  void stop() {
    _confettiController.stop();
  }

  void dispose() {
    _confettiController.dispose();
  }

  Widget buildConfettiWidget({
    required Widget child,
    Alignment alignment = Alignment.topCenter,
  }) {
    return Stack(
      children: [
        child,
        Align(
          alignment: alignment,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: getBlastDirection(alignment),
            particleDrag: 0.05,
            emissionFrequency: getEmissionFrequency(),
            numberOfParticles: getNumberOfParticles(),
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.yellow,
            ],
            strokeWidth: 1,
            strokeColor: Colors.white,
            maxBlastForce: getMaxBlastForce(),
            minBlastForce: getMinBlastForce(),
            blastDirectionality: BlastDirectionality.explosive,
          ),
        ),
      ],
    );
  }

  double getBlastDirection(Alignment alignment) {
    if (alignment == Alignment.topCenter) {
      return pi / 2; // Downward
    } else if (alignment == Alignment.centerLeft) {
      return 0; // Right
    } else if (alignment == Alignment.centerRight) {
      return pi; // Left
    } else if (alignment == Alignment.bottomCenter) {
      return -pi / 2; // Upward
    } else {
      return pi / 2; // Default downward
    }
  }

  double getEmissionFrequency() {
    switch (intensity) {
      case ConfettiIntensity.low:
        return 0.05;
      case ConfettiIntensity.medium:
        return 0.1;
      case ConfettiIntensity.high:
        return 0.3;
    }
  }

  int getNumberOfParticles() {
    switch (intensity) {
      case ConfettiIntensity.low:
        return 10;
      case ConfettiIntensity.medium:
        return 30;
      case ConfettiIntensity.high:
        return 50;
    }
  }

  double getMaxBlastForce() {
    switch (intensity) {
      case ConfettiIntensity.low:
        return 20;
      case ConfettiIntensity.medium:
        return 30;
      case ConfettiIntensity.high:
        return 40;
    }
  }

  double getMinBlastForce() {
    switch (intensity) {
      case ConfettiIntensity.low:
        return 5;
      case ConfettiIntensity.medium:
        return 10;
      case ConfettiIntensity.high:
        return 20;
    }
  }
}
