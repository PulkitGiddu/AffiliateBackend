// Run from app root: dart run tool/create_icon_square.dart
// Creates a square PNG with logo2 centered and aspect ratio preserved (no stretch).
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // When run via "dart run tool/..." from app root, cwd is app root
  final cwd = Directory.current.path;
  final logoPath = '$cwd/lib/asserts/logo2.png';
  final outPath = '$cwd/lib/asserts/logo2.png';

  final logoFile = File(logoPath);
  if (!logoFile.existsSync()) {
    print('Error: $logoPath not found');
    exit(1);
  }

  final bytes = logoFile.readAsBytesSync();
  final logo = img.decodeImage(bytes);
  if (logo == null) {
    print('Error: could not decode logo image');
    exit(1);
  }

  const size = 1024;
  // Scale logo to fit inside [size x size], preserving aspect ratio (no stretch)
  final scaleW = size / logo.width;
  final scaleH = size / logo.height;
  final scaleUniform = scaleW < scaleH ? scaleW : scaleH;
  final w = (logo.width * scaleUniform).round().clamp(1, size);
  final h = (logo.height * scaleUniform).round().clamp(1, size);

  final resized = img.copyResize(logo, width: w, height: h, interpolation: img.Interpolation.cubic);

  // Square canvas (transparent)
  final canvas = img.Image(width: size, height: size);
  final x = (size - w) ~/ 2;
  final y = (size - h) ~/ 2;
  img.compositeImage(canvas, resized, dstX: x, dstY: y);

  File(outPath).writeAsBytesSync(img.encodePng(canvas));
  print('Wrote $outPath (${w}x$h logo on ${size}x$size canvas)');
}
