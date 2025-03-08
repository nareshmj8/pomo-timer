import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

Future<void> generateSplashIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  const size = Size(512, 512);

  // Draw transparent background
  canvas.drawRect(
    Offset.zero & size,
    Paint()..color = Colors.transparent,
  );

  // Draw timer circle
  final circlePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = size.width * 0.08;

  canvas.drawCircle(
    Offset(size.width * 0.5, size.height * 0.5),
    size.width * 0.35,
    circlePaint,
  );

  // Draw timer hands
  final handPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  // Minute hand
  canvas.save();
  canvas.translate(size.width * 0.5, size.height * 0.5);
  canvas.rotate(-0.5);
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(0, -size.height * 0.2),
      width: size.width * 0.04,
      height: size.height * 0.3,
    ),
    handPaint,
  );
  canvas.restore();

  // Hour hand
  canvas.save();
  canvas.translate(size.width * 0.5, size.height * 0.5);
  canvas.rotate(0.5);
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(0, -size.height * 0.15),
      width: size.width * 0.04,
      height: size.height * 0.2,
    ),
    handPaint,
  );
  canvas.restore();

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);

  if (data != null) {
    final bytes = data.buffer.asUint8List();
    final file = File('assets/splash.png');
    await file.writeAsBytes(bytes);
    print('Splash icon generated successfully!');
  } else {
    print('Failed to generate splash icon.');
  }
}

Future<void> generateBranding() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  const size = Size(800, 100); // Wide rectangle for the text

  // Draw transparent background
  canvas.drawRect(
    Offset.zero & size,
    Paint()..color = Colors.transparent,
  );

  // Create paragraph for text
  final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.center,
    fontSize: 72,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto',
  ))
    ..pushStyle(ui.TextStyle(color: Colors.white))
    ..addText('Pomo Timer');

  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: size.width));

  // Draw text centered
  canvas.drawParagraph(
    paragraph,
    Offset(0, (size.height - paragraph.height) / 2),
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);

  if (data != null) {
    final bytes = data.buffer.asUint8List();
    final file = File('assets/branding.png');
    await file.writeAsBytes(bytes);
    print('Branding image generated successfully!');
  } else {
    print('Failed to generate branding image.');
  }
}

void main() async {
  await generateSplashIcon();
  await generateBranding();
}
