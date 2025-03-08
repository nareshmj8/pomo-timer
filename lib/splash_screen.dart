import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      Transform.rotate(
                        angle: -0.5,
                        child: Container(
                          width: 8,
                          height: 80,
                          color: Colors.blue,
                        ),
                      ),
                      Transform.rotate(
                        angle: 0.5,
                        child: Container(
                          width: 8,
                          height: 60,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pomo Timer',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
